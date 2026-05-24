import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../i18n/strings.dart';
import '../models/driver.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import '../widgets/babi_icon.dart';
import '../widgets/common.dart';
import '../widgets/map_chrome.dart';
import '../widgets/real_map.dart';

const _avatarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF39423), Color(0xFFC75F00)],
);

class ArrivingScreen extends StatefulWidget {
  final Strings t;
  final bool dark;
  final Driver driver;
  final LatLng pickup;
  final VoidCallback onStartTrip;
  final VoidCallback onCancel;

  const ArrivingScreen({
    super.key,
    required this.t,
    required this.dark,
    required this.driver,
    required this.pickup,
    required this.onStartTrip,
    required this.onCancel,
  });

  @override
  State<ArrivingScreen> createState() => _ArrivingScreenState();
}

class _ArrivingScreenState extends State<ArrivingScreen> {
  int _eta = 3;
  Timer? _tick;
  Timer? _start;

  /// Driver approaches the pickup from a point ~700 m to the north-east.
  LatLng get _start0 => LatLng(widget.pickup.latitude + 0.006, widget.pickup.longitude + 0.006);
  LatLng get _end => widget.pickup;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      setState(() => _eta = (_eta - 1).clamp(0, 3));
      if (_eta == 0) {
        _tick?.cancel();
        _start = Timer(const Duration(milliseconds: 1400), widget.onStartTrip);
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _start?.cancel();
    super.dispose();
  }

  LatLng get _carPos {
    final progress = (3 - _eta) / 3;
    return LatLng(
      _start0.latitude + (_end.latitude - _start0.latitude) * progress,
      _start0.longitude + (_end.longitude - _start0.longitude) * progress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.dark ? AppColors.mapLandDark : AppColors.mapLand,
      child: Stack(
        children: [
          Positioned.fill(
            child: RealMap(
              center: widget.pickup,
              zoom: 15.5,
              dark: widget.dark,
              pickup: widget.pickup,
              car: _carPos,
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
    final plateParts = d.plate.split(' ');
    return BottomSheetCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((_eta == 0 ? widget.t.arrivedDriver : widget.t.driverArrives).toUpperCase(),
                          style: AppTheme.manrope(size: 12, weight: FontWeight.w600, color: AppColors.ink3, letterSpacing: 0.72)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(_eta == 0 ? widget.t.nowLabel : '$_eta',
                              style: AppTheme.numeric(size: 36, weight: FontWeight.w700, letterSpacing: -0.72)),
                          if (_eta != 0) ...[
                            const SizedBox(width: 4),
                            Text(widget.t.min, style: AppTheme.manrope(size: 18, weight: FontWeight.w600, color: AppColors.ink2)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.orangeSoft, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text(plateParts.first,
                          style: AppTheme.numeric(size: 17, weight: FontWeight.w800, color: AppColors.orangeDeep, height: 1)),
                      const SizedBox(height: 2),
                      Text(plateParts.length > 1 ? plateParts.sublist(1).join(' ') : '',
                          style: AppTheme.manrope(size: 10, weight: FontWeight.w700, color: AppColors.orangeDeep, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _driverCard(d),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: BabiChip(label: widget.t.safety, icon: 'shield', height: 44, expand: true)),
              const SizedBox(width: 8),
              Expanded(child: BabiChip(label: widget.t.share, icon: 'share', height: 44, expand: true)),
              const SizedBox(width: 8),
              Expanded(
                child: BabiChip(
                  label: widget.t.cancel,
                  icon: 'x',
                  height: 44,
                  expand: true,
                  foreground: AppColors.rose,
                  onTap: widget.onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _driverCard(Driver d) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _avatar(d.avatarInitial.isEmpty ? 'K' : d.avatarInitial, 52, 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name, style: AppTheme.manrope(size: 15, weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const BabiIcon('star', size: 12, color: AppColors.orange),
                    const SizedBox(width: 4),
                    Text(d.rating.toStringAsFixed(2),
                        style: AppTheme.numeric(size: 12, weight: FontWeight.w700)),
                    Text('  ·  ', style: AppTheme.manrope(size: 12, color: AppColors.ink3)),
                    Text(groupThousands(d.tripsCount),
                        style: AppTheme.numeric(size: 12, weight: FontWeight.w600, color: AppColors.ink3)),
                    Text(' ${widget.t.trips}', style: AppTheme.manrope(size: 12, color: AppColors.ink3)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${d.carMake} · ${d.carColor(widget.t.isFr)}',
                    style: AppTheme.manrope(size: 12, weight: FontWeight.w600, color: AppColors.ink2)),
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

  static Widget _avatar(String initial, double size, double fontSize) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(gradient: _avatarGradient, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initial, style: AppTheme.manrope(size: fontSize, weight: FontWeight.w700, color: Colors.white)),
    );
  }
}
