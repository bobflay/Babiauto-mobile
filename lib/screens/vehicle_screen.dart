import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../models/vehicle_class.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import '../widgets/babi_icon.dart';
import '../widgets/babi_map.dart';
import '../widgets/common.dart';
import '../widgets/map_chrome.dart';
import '../widgets/vehicle_art.dart';

class VehicleScreen extends StatelessWidget {
  final Strings t;
  final bool dark;
  final String destName;
  final List<VehicleClass> classes;
  final int Function(String slug) priceFor;
  final int Function(String slug) etaFor;
  final String selected;
  final String payment;
  final int confirmPrice;
  final ValueChanged<String> onPick;
  final ValueChanged<String> onPayChange;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const VehicleScreen({
    super.key,
    required this.t,
    required this.dark,
    required this.destName,
    required this.classes,
    required this.priceFor,
    required this.etaFor,
    required this.selected,
    required this.payment,
    required this.confirmPrice,
    required this.onPick,
    required this.onPayChange,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: dark ? AppColors.mapLandDark : AppColors.mapLand,
      child: Stack(
        children: [
          const Positioned.fill(
            child: BabiMap(
              pickup: Offset(200, 230),
              dropoff: Offset(260, 680),
              showUser: false,
            ),
          ),
          MapTopBar(dark: dark, onMenu: onBack),
          // pickup / drop summary
          Positioned(
            top: 96,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: _summaryCard(),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: _sheet()),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xEB262019) : const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          _SummaryRow(dot: AppColors.green, label: 'Cocody · Riviera Golf', dark: dark),
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 8, bottom: 8),
            child: Container(height: 1, color: AppColors.inkA(0.08)),
          ),
          _SummaryRow(dot: AppColors.ink, square: true, label: destName, dark: dark),
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
            padding: const EdgeInsets.only(top: 2, bottom: 12),
            child: Text(t.vehicleClass, style: AppTheme.manrope(size: 20, weight: FontWeight.w800, letterSpacing: -0.2)),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 252),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: classes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final v = classes[i];
                return _VehicleRow(
                  t: t,
                  vehicle: v,
                  price: priceFor(v.slug),
                  eta: etaFor(v.slug),
                  selected: selected == v.slug,
                  onTap: () => onPick(v.slug),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _paymentSelector(),
          const SizedBox(height: 14),
          CtaButton(
            orange: true,
            onTap: onConfirm,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${t.confirm} · '),
                Text('${groupThousands(confirmPrice)} F',
                    style: AppTheme.numeric(size: 17, weight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _payIcon(payment),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.paymentMethod.toUpperCase(),
                    style: AppTheme.manrope(size: 11, weight: FontWeight.w600, color: AppColors.ink3, letterSpacing: 0.66)),
                Text(_paymentLabel(payment), style: AppTheme.manrope(size: 14, weight: FontWeight.w700)),
              ],
            ),
          ),
          _payPill('cash'),
          const SizedBox(width: 6),
          _payPill('mobile'),
          const SizedBox(width: 6),
          _payPill('card'),
        ],
      ),
    );
  }

  Widget _payIcon(String m) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      alignment: Alignment.center,
      child: BabiIcon(m, size: 16, color: AppColors.ink),
    );
  }

  Widget _payPill(String m) {
    final active = payment == m;
    return Pressable(
      onTap: () => onPayChange(m),
      child: Container(
        width: 36,
        height: 32,
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        alignment: Alignment.center,
        child: BabiIcon(m, size: 15, color: active ? Colors.white : AppColors.ink2),
      ),
    );
  }

  String _paymentLabel(String m) {
    switch (m) {
      case 'cash':
        return t.payCash;
      case 'mobile':
        return '${t.payMobile} · Orange';
      case 'card':
        return '${t.payCard} · •• 4127';
      default:
        return '';
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final Color dot;
  final bool square;
  final String label;
  final bool dark;
  const _SummaryRow({required this.dot, required this.label, this.square = false, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        square
            ? Container(width: 10, height: 10, color: dot)
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: dot.withValues(alpha: 0.2), spreadRadius: 3)],
                ),
              ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.manrope(size: 14, weight: FontWeight.w600, color: dark ? Colors.white : AppColors.ink)),
        ),
      ],
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final Strings t;
  final VehicleClass vehicle;
  final int price;
  final int eta;
  final bool selected;
  final VoidCallback onTap;
  const _VehicleRow({
    required this.t,
    required this.vehicle,
    required this.price,
    required this.eta,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.paper2,
          borderRadius: BorderRadius.circular(16),
          border: selected ? null : Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            VehicleArt(slug: vehicle.slug, selected: selected),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(vehicle.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.manrope(size: 16, weight: FontWeight.w800, color: fg)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.whiteA(0.16) : AppColors.inkA(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${vehicle.seats}',
                            style: AppTheme.manrope(size: 11, weight: FontWeight.w600, color: fg)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('${vehicle.description(t.isFr)} · ',
                          style: AppTheme.manrope(size: 12, color: fg.withValues(alpha: 0.7))),
                      Text('$eta ${t.min}',
                          style: AppTheme.numeric(size: 12, weight: FontWeight.w600, color: fg.withValues(alpha: 0.7))),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(groupThousands(price),
                    style: AppTheme.numeric(size: 17, weight: FontWeight.w800, color: fg)),
                Text('F CFA',
                    style: AppTheme.manrope(size: 11, weight: FontWeight.w600, color: fg.withValues(alpha: 0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
