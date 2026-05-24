import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_colors.dart';

/// Real tile map (CartoDB / OpenStreetMap) replacing the stylized SVG map.
/// Coordinates are geographic (lat/lng) throughout.
class RealMap extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final bool dark;
  final LatLng? user;
  final LatLng? pickup;
  final LatLng? dropoff;
  final LatLng? car;
  final List<LatLng> route;
  final bool fitToRoute;
  final bool interactive;

  /// Extra flutter_map layers (e.g. live nearby cars) drawn above the route
  /// and below the pickup/drop/user markers.
  final List<Widget> layers;

  const RealMap({
    super.key,
    required this.center,
    this.zoom = 14.5,
    this.dark = false,
    this.user,
    this.pickup,
    this.dropoff,
    this.car,
    this.route = const [],
    this.fitToRoute = false,
    this.interactive = true,
    this.layers = const [],
  });

  @override
  State<RealMap> createState() => _RealMapState();
}

class _RealMapState extends State<RealMap> {
  final MapController _controller = MapController();
  bool _ready = false;

  @override
  void didUpdateWidget(RealMap old) {
    super.didUpdateWidget(old);
    if (!_ready) return;
    if (widget.fitToRoute && (old.route.length != route.length || old.dropoff != widget.dropoff)) {
      _fit();
    } else if (!widget.fitToRoute && old.center != widget.center) {
      _controller.move(widget.center, widget.zoom);
    }
  }

  List<LatLng> get route =>
      widget.route.isNotEmpty ? widget.route : [if (widget.pickup != null) widget.pickup!, if (widget.dropoff != null) widget.dropoff!];

  void _fit() {
    final pts = [
      ...route,
      if (widget.pickup != null) widget.pickup!,
      if (widget.dropoff != null) widget.dropoff!,
    ];
    if (pts.length < 2) return;
    _controller.fitCamera(
      CameraFit.coordinates(coordinates: pts, padding: const EdgeInsets.fromLTRB(56, 120, 56, 360)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = widget.dark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: widget.zoom,
        backgroundColor: widget.dark ? AppColors.mapLandDark : AppColors.mapLand,
        interactionOptions: InteractionOptions(
          flags: widget.interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
        onMapReady: () {
          _ready = true;
          if (widget.fitToRoute) _fit();
        },
      ),
      children: [
        TileLayer(
          urlTemplate: tiles,
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'ci.babiauto.app',
          maxZoom: 19,
          tileProvider: NetworkTileProvider(),
        ),
        if (route.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: route,
                strokeWidth: 9,
                color: (widget.dark ? Colors.black : Colors.white).withValues(alpha: 0.85),
              ),
              Polyline(points: route, strokeWidth: 5, color: AppColors.orange),
            ],
          ),
        ...widget.layers,
        MarkerLayer(
          markers: [
            if (widget.pickup != null)
              Marker(point: widget.pickup!, width: 26, height: 26, child: const _PickupDot()),
            if (widget.dropoff != null)
              Marker(
                point: widget.dropoff!,
                width: 40,
                height: 44,
                alignment: Alignment.topCenter,
                child: const _DropPin(),
              ),
            if (widget.car != null)
              Marker(point: widget.car!, width: 40, height: 40, child: const _CarMarker()),
            if (widget.user != null && widget.car == null)
              Marker(point: widget.user!, width: 46, height: 46, child: const _UserDot()),
          ],
        ),
        _attribution(),
      ],
    );
  }

  Widget _attribution() => RichAttributionWidget(
        alignment: AttributionAlignment.bottomLeft,
        attributions: [
          TextSourceAttribution('OpenStreetMap', onTap: () {}),
          TextSourceAttribution('CARTO', onTap: () {}),
        ],
      );
}

class _PickupDot extends StatelessWidget {
  const _PickupDot();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}

class _DropPin extends StatelessWidget {
  const _DropPin();
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.location_on, color: AppColors.ink, size: 40, shadows: [
      Shadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2)),
    ]);
  }
}

class _CarMarker extends StatelessWidget {
  const _CarMarker();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.local_taxi, color: AppColors.orange, size: 19),
      ),
    );
  }
}

class _UserDot extends StatefulWidget {
  const _UserDot();
  @override
  State<_UserDot> createState() => _UserDotState();
}

class _UserDotState extends State<_UserDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final r = 10 + 13 * _c.value;
        final op = (0.35 - 0.3 * _c.value).clamp(0.0, 1.0);
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: r * 2,
                height: r * 2,
                decoration: BoxDecoration(color: AppColors.lagoon.withValues(alpha: op), shape: BoxShape.circle),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.lagoon,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
