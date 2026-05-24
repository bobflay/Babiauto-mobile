import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/nearby_driver.dart';
import '../theme/app_colors.dart';

/// A flutter_map layer that polls `GET /drivers/nearby` and renders one car
/// marker per result, gliding smoothly between polls (matched by id) and
/// rotated by heading. Drop it into [FlutterMap.children].
///
/// Lives inside the map, so it must be built as a child of [FlutterMap]; the
/// markers then track pan/zoom. Polling starts on mount and stops on dispose
/// (i.e. when the home screen leaves the tree / a ride starts), and pauses
/// while the app is backgrounded.
class NearbyCarsLayer extends StatefulWidget {
  final LatLng center;
  final String? vehicleClass;
  final Future<NearbyDriversResult> Function(LatLng center, {String? vehicleClass}) fetch;
  final ValueChanged<bool>? onSimulated;
  final Duration interval;

  const NearbyCarsLayer({
    super.key,
    required this.center,
    required this.fetch,
    this.vehicleClass,
    this.onSimulated,
    this.interval = const Duration(seconds: 5),
  });

  @override
  State<NearbyCarsLayer> createState() => _NearbyCarsLayerState();
}

class _Track {
  final LatLng from;
  final LatLng to;
  final double fromHeading;
  final double toHeading;
  final String vehicleClass;
  const _Track(this.from, this.to, this.fromHeading, this.toHeading, this.vehicleClass);
}

class _NearbyCarsLayerState extends State<NearbyCarsLayer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final Map<int, _Track> _tracks = {};
  Timer? _timer;
  bool _polling = false;
  // Glide over a window wider than the poll interval so cars ease toward the
  // latest position at a calmer pace (they track with a slight, intentional lag
  // rather than darting the full jump each tick).
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.interval.inMilliseconds * 1.6).round()),
  )..addListener(_onTick);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      _stop();
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _start() {
    _timer ??= Timer.periodic(widget.interval, (_) => _poll());
    _poll();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final result = await widget.fetch(widget.center, vehicleClass: widget.vehicleClass);
      if (!mounted) return;
      widget.onSimulated?.call(result.simulated);
      _ingest(result.drivers); // empty list legitimately clears markers
    } catch (_) {
      // Keep last-known markers; retry on the next tick.
    } finally {
      _polling = false;
    }
  }

  void _ingest(List<NearbyDriver> drivers) {
    final t = _anim.value;
    final seen = <int>{};
    for (final d in drivers) {
      seen.add(d.id);
      final prev = _tracks[d.id];
      if (prev == null) {
        _tracks[d.id] = _Track(d.latLng, d.latLng, d.heading, d.heading, d.vehicleClass);
      } else {
        _tracks[d.id] = _Track(
          _lerpLatLng(prev.from, prev.to, t),
          d.latLng,
          _lerpAngle(prev.fromHeading, prev.toHeading, t),
          d.heading,
          d.vehicleClass,
        );
      }
    }
    _tracks.removeWhere((id, _) => !seen.contains(id));
    _anim.forward(from: 0);
    if (mounted) setState(() {});
  }

  static LatLng _lerpLatLng(LatLng a, LatLng b, double t) => LatLng(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      );

  static double _lerpAngle(double a, double b, double t) {
    var diff = (b - a) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return a + diff * t;
  }

  @override
  Widget build(BuildContext context) {
    final t = _anim.value;
    final markers = _tracks.values.map((track) {
      return Marker(
        point: _lerpLatLng(track.from, track.to, t),
        width: 34,
        height: 34,
        child: _CarDot(
          vehicleClass: track.vehicleClass,
          headingDeg: _lerpAngle(track.fromHeading, track.toHeading, t),
        ),
      );
    }).toList();
    return MarkerLayer(markers: markers);
  }
}

class _CarDot extends StatelessWidget {
  final String vehicleClass;
  final double headingDeg;
  const _CarDot({required this.vehicleClass, required this.headingDeg});

  static const _colors = {
    'moto': AppColors.lagoon,
    'mini': AppColors.green,
    'confort': AppColors.orange,
    'xl': AppColors.ink2,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[vehicleClass] ?? AppColors.orange;
    // Top-down car silhouette: rotates naturally to face its travel bearing.
    return Transform.rotate(
      angle: headingDeg * math.pi / 180, // compass bearing → clockwise radians
      child: CustomPaint(size: const Size(34, 34), painter: _CarTopPainter(color)),
    );
  }
}

class _CarTopPainter extends CustomPainter {
  final Color color;
  _CarTopPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 14, height: 22),
      const Radius.circular(4.5),
    );

    // soft drop shadow
    canvas.drawRRect(
      body.shift(const Offset(0, 1.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    // body
    canvas.drawRRect(body, Paint()..color = color);
    // outline for contrast on any tile
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = Colors.white.withValues(alpha: 0.9),
    );
    // windshield (front, toward travel direction) + rear window
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 5.5), width: 9, height: 4.5), const Radius.circular(2)),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 5.5), width: 9, height: 4), const Radius.circular(2)),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _CarTopPainter old) => old.color != color;
}
