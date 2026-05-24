import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../i18n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/babi_icon.dart';
import '../widgets/common.dart';
import '../widgets/real_map.dart';

class FindingScreen extends StatefulWidget {
  final Strings t;
  final bool dark;
  final LatLng center;
  final double distanceKm;
  final int durationMinutes;
  final int driverEtaMinutes;
  final VoidCallback onArrived;
  final VoidCallback onCancel;

  const FindingScreen({
    super.key,
    required this.t,
    required this.dark,
    required this.center,
    required this.distanceKm,
    required this.durationMinutes,
    required this.driverEtaMinutes,
    required this.onArrived,
    required this.onCancel,
  });

  @override
  State<FindingScreen> createState() => _FindingScreenState();
}

class _FindingScreenState extends State<FindingScreen> with TickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  late final AnimationController _shimmer =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    _auto = Timer(const Duration(milliseconds: 4500), widget.onArrived);
  }

  @override
  void dispose() {
    _auto?.cancel();
    _ring.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  String get _dist => '${widget.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.dark ? AppColors.mapLandDark : AppColors.mapLand,
      child: Stack(
        children: [
          Positioned.fill(
            child: RealMap(center: widget.center, dark: widget.dark, zoom: 15, interactive: false),
          ),
          Align(
            alignment: const Alignment(0, -0.3),
            child: SizedBox(width: 120, height: 120, child: _radar()),
          ),
          Align(alignment: Alignment.bottomCenter, child: _sheet()),
        ],
      ),
    );
  }

  Widget _radar() {
    return AnimatedBuilder(
      animation: _ring,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (final delay in [0.0, 0.3, 0.6]) _ringFor(delay),
            child!,
          ],
        );
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.orange,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: const BabiIcon('search', size: 22, color: Colors.white, strokeWidth: 2.4),
      ),
    );
  }

  Widget _ringFor(double delay) {
    final v = (_ring.value + delay) % 1.0;
    final scale = 0.6 + v * 1.8; // 0.6 → 2.4
    final opacity = (0.7 * (1 - v)).clamp(0.0, 1.0);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.orange.withValues(alpha: opacity), width: 2),
        ),
      ),
    );
  }

  Widget _sheet() {
    return BottomSheetCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.t.searching, style: AppTheme.manrope(size: 22, weight: FontWeight.w800, letterSpacing: -0.22)),
                const SizedBox(height: 4),
                Text(widget.t.searchingSub, style: AppTheme.manrope(size: 14, color: AppColors.ink3)),
              ],
            ),
          ),
          // shimmer progress
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 4,
              color: AppColors.paper2,
              child: AnimatedBuilder(
                animation: _shimmer,
                builder: (context, _) => LayoutBuilder(builder: (context, c) {
                  final w = c.maxWidth;
                  return Stack(children: [
                    Positioned(
                      left: -w * 0.4 + _shimmer.value * w * 1.4,
                      width: w * 0.4,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0x00F39423), AppColors.orange, Color(0x00F39423)]),
                        ),
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              StatTile(label: widget.t.distance, value: _dist),
              const SizedBox(width: 10),
              StatTile(label: widget.t.estimateArrival, value: '~${widget.durationMinutes} min'),
              const SizedBox(width: 10),
              StatTile(label: widget.t.driverEta, value: '${widget.driverEtaMinutes} min'),
            ],
          ),
          const SizedBox(height: 18),
          NeutralButton(label: widget.t.cancel, onTap: widget.onCancel),
        ],
      ),
    );
  }
}
