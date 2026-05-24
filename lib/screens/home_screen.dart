import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../i18n/strings.dart';
import '../models/nearby_driver.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/babi_icon.dart';
import '../widgets/common.dart';
import '../widgets/map_chrome.dart';
import '../widgets/nearby_cars_layer.dart';
import '../widgets/real_map.dart';

typedef NearbyFetch = Future<NearbyDriversResult> Function(LatLng center, {String? vehicleClass});

class HomeScreen extends StatelessWidget {
  final Strings t;
  final bool dark;
  final String riderName;
  final LatLng center;
  final String locationLabel;
  final bool locating;
  final VoidCallback onSearch;
  final VoidCallback onSavedPick;
  final VoidCallback? onRecenter;
  final VoidCallback? onMenu;
  final VoidCallback? onProfile;
  final NearbyFetch? nearby;

  const HomeScreen({
    super.key,
    required this.t,
    required this.dark,
    required this.riderName,
    required this.center,
    required this.locationLabel,
    this.locating = false,
    required this.onSearch,
    required this.onSavedPick,
    this.onRecenter,
    this.onMenu,
    this.onProfile,
    this.nearby,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dark ? AppColors.mapLandDark : AppColors.mapLand,
      child: Stack(
        children: [
          Positioned.fill(
            child: _HomeMap(t: t, center: center, dark: dark, nearby: nearby),
          ),
          MapTopBar(dark: dark, initial: riderName.substring(0, 1), onMenu: onMenu, onProfile: onProfile),
          // current-location pill
          Align(
            alignment: const Alignment(0, -0.28),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (locating) ...[
                    const SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(strokeWidth: 1.8, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(locating ? t.locating : locationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.manrope(size: 12, weight: FontWeight.w600, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          // recenter
          Align(
            alignment: const Alignment(0.92, 0.34),
            child: FloatButton(
              dark: dark,
              onTap: onRecenter,
              child: BabiIcon('crosshair', size: 20, color: dark ? Colors.white : AppColors.ink),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: _sheet()),
        ],
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
            padding: const EdgeInsets.only(top: 2, bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.greetName(riderName),
                          style: AppTheme.manrope(size: 13, weight: FontWeight.w600, color: AppColors.ink3)),
                      const SizedBox(height: 2),
                      Text(t.whereTo,
                          style: AppTheme.manrope(size: 22, weight: FontWeight.w800, letterSpacing: -0.22)),
                    ],
                  ),
                ),
                _nowPill(),
              ],
            ),
          ),
          _searchTrigger(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SavedTile(label: t.home, sub: 'Cocody · Riviera 3', icon: 'home', onTap: onSavedPick)),
              const SizedBox(width: 10),
              Expanded(child: _SavedTile(label: t.work, sub: 'Plateau · Av. Chardy', icon: 'work', onTap: onSavedPick)),
              const SizedBox(width: 10),
              Expanded(child: _SavedTile(label: '+', sub: t.add, icon: 'plus', muted: true, onTap: () {})),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nowPill() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BabiIcon('clock', size: 14, color: AppColors.ink2),
          const SizedBox(width: 6),
          Text(t.now, style: AppTheme.manrope(size: 13, weight: FontWeight.w600, color: AppColors.ink2)),
          const SizedBox(width: 6),
          const BabiIcon('chevronD', size: 14, color: AppColors.ink2),
        ],
      ),
    );
  }

  Widget _searchTrigger() {
    return Pressable(
      onTap: onSearch,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: const [BoxShadow(color: Color(0x0F1A1612), blurRadius: 16, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            const BabiIcon('search', size: 20, color: AppColors.ink3),
            const SizedBox(width: 12),
            Expanded(
              child: Text(t.destination,
                  style: AppTheme.manrope(size: 16, weight: FontWeight.w500, color: AppColors.ink3)),
            ),
            BabiChip(
              label: t.suggest,
              icon: 'sparkle',
              height: 30,
              fontSize: 12,
              background: AppColors.orangeSoft,
              foreground: AppColors.orangeDeep,
            ),
          ],
        ),
      ),
    );
  }
}

/// The map area: real tiles + live nearby cars, with a small "demo" hint when
/// the backend reports simulated positions. Owns the simulated flag so the
/// rest of [HomeScreen] can stay stateless.
class _HomeMap extends StatefulWidget {
  final Strings t;
  final LatLng center;
  final bool dark;
  final NearbyFetch? nearby;
  const _HomeMap({required this.t, required this.center, required this.dark, this.nearby});

  @override
  State<_HomeMap> createState() => _HomeMapState();
}

class _HomeMapState extends State<_HomeMap> {
  bool _simulated = false;

  void _setSimulated(bool v) {
    if (v != _simulated && mounted) setState(() => _simulated = v);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RealMap(
            center: widget.center,
            zoom: 15,
            dark: widget.dark,
            user: widget.center,
            layers: [
              if (widget.nearby != null)
                NearbyCarsLayer(
                  center: widget.center,
                  fetch: widget.nearby!,
                  onSimulated: _setSimulated,
                ),
            ],
          ),
        ),
        if (_simulated)
          Align(
            alignment: const Alignment(0, -0.92),
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inkA(0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _Dot(),
                    const SizedBox(width: 6),
                    Text(widget.t.carsSimulated,
                        style: AppTheme.manrope(size: 10, weight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
      );
}

class _SavedTile extends StatelessWidget {
  final String label;
  final String sub;
  final String icon;
  final bool muted;
  final VoidCallback onTap;
  const _SavedTile({
    required this.label,
    required this.sub,
    required this.icon,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = muted ? AppColors.ink3 : AppColors.ink2;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: muted ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: muted
              ? Border.all(color: AppColors.line2, width: 1.5, style: BorderStyle.solid)
              : Border.all(color: AppColors.line),
          boxShadow: muted ? null : const [BoxShadow(color: Color(0x0A1A1612), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BabiIcon(icon, size: 14, color: fg),
                const SizedBox(width: 6),
                Text(label, style: AppTheme.manrope(size: 13, weight: FontWeight.w700, color: fg)),
              ],
            ),
            const SizedBox(height: 2),
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.manrope(size: 11, weight: FontWeight.w500, color: AppColors.ink3)),
          ],
        ),
      ),
    );
  }
}
