import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../i18n/strings.dart';
import '../models/driver.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../util/geo.dart';
import '../widgets/common.dart';
import '../widgets/map_chrome.dart';
import '../widgets/real_map.dart';

class OnTripScreen extends StatefulWidget {
  final Strings t;
  final bool dark;
  final Driver driver;
  final LatLng pickup;
  final LatLng dropoff;
  final List<LatLng> route;
  final String originLabel;
  final String destLabel;
  final VoidCallback onComplete;

  const OnTripScreen({
    super.key,
    required this.t,
    required this.dark,
    required this.driver,
    required this.pickup,
    required this.dropoff,
    required this.route,
    required this.originLabel,
    required this.destLabel,
    required this.onComplete,
  });

  @override
  State<OnTripScreen> createState() => _OnTripScreenState();
}

class _OnTripScreenState extends State<OnTripScreen> {
  double _progress = 0;
  int _eta = 28;
  Timer? _timer;
  Timer? _done;

  List<LatLng> get _line => widget.route.length >= 2 ? widget.route : [widget.pickup, widget.dropoff];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 280), (_) {
      setState(() {
        _progress = (_progress + 0.04).clamp(0, 1);
        _eta = (_eta - 1).clamp(0, 28);
      });
      if (_progress >= 1) {
        _timer?.cancel();
        _done = Timer(const Duration(milliseconds: 800), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _done?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final car = pointAlongRoute(_line, _progress);
    return Container(
      color: widget.dark ? AppColors.mapLandDark : AppColors.mapLand,
      child: Stack(
        children: [
          Positioned.fill(
            child: RealMap(
              center: car,
              dark: widget.dark,
              pickup: widget.pickup,
              dropoff: widget.dropoff,
              route: widget.route,
              car: car,
              fitToRoute: true,
              interactive: false,
            ),
          ),
          MapTopBar(dark: widget.dark),
          Align(alignment: Alignment.bottomCenter, child: _sheet()),
        ],
      ),
    );
  }

  Widget _sheet() {
    final d = widget.driver;
    return BottomSheetCard(
      animate: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.t.toDestination.toUpperCase(),
                        style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.72)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$_eta', style: AppTheme.numeric(size: 40, weight: FontWeight.w700, letterSpacing: -0.8)),
                        const SizedBox(width: 6),
                        Text(widget.t.min, style: AppTheme.manrope(size: 18, weight: FontWeight.w600, color: AppColors.ink2)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.t.arrival.toUpperCase(),
                      style: AppTheme.manrope(size: 11, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.66)),
                  Text('14:38', style: AppTheme.numeric(size: 20, weight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: AppColors.paper2,
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.originLabel, style: AppTheme.manrope(size: 11, weight: FontWeight.w600, color: AppColors.ink3)),
              Flexible(
                child: Text(widget.destLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTheme.manrope(size: 11, weight: FontWeight.w600, color: AppColors.ink3)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _miniDriverRow(d),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: BabiChip(label: widget.t.safety, icon: 'shield', height: 44, expand: true)),
              const SizedBox(width: 8),
              Expanded(child: BabiChip(label: widget.t.share, icon: 'share', height: 44, expand: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniDriverRow(Driver d) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF39423), Color(0xFFC75F00)],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(d.avatarInitial.isEmpty ? 'K' : d.avatarInitial,
                style: AppTheme.manrope(size: 14, weight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name, style: AppTheme.manrope(size: 13, weight: FontWeight.w700)),
                Text('${d.carMake} · ${d.plate}',
                    style: AppTheme.manrope(size: 11, weight: FontWeight.w600, color: AppColors.ink3)),
              ],
            ),
          ),
          const CircleButton(icon: 'msg'),
          const SizedBox(width: 8),
          const CircleButton(icon: 'phone', primary: true),
        ],
      ),
    );
  }
}
