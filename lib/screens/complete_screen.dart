import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../models/driver.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import '../widgets/babi_icon.dart';
import '../widgets/common.dart';

class CompleteScreen extends StatefulWidget {
  final Strings t;
  final Driver driver;
  final String paymentType;
  final String pickupName;
  final String destName;
  final int baseFare;
  final int airportFee;
  final double distanceKm;
  final int durationMinutes;
  final void Function(int stars, int tip) onDone;

  const CompleteScreen({
    super.key,
    required this.t,
    required this.driver,
    required this.paymentType,
    required this.pickupName,
    required this.destName,
    required this.baseFare,
    required this.airportFee,
    required this.distanceKm,
    required this.durationMinutes,
    required this.onDone,
  });

  @override
  State<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen> {
  int _stars = 0;
  int _tip = 0;

  int get _subtotal => widget.baseFare + widget.airportFee;
  int get _total => _subtotal + _tip;

  String get _dist => '${widget.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';

  String _paymentLabel() {
    switch (widget.paymentType) {
      case 'cash':
        return widget.t.payCash;
      case 'mobile':
        return '${widget.t.payMobile} · Orange';
      case 'card':
        return '${widget.t.payCard} · •• 4127';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paper,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: AppColors.paper2, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const BabiIcon('x', size: 18),
                  ),
                  Text('23 mai 2026 · 14:38',
                      style: AppTheme.manrope(size: 13, weight: FontWeight.w600, color: AppColors.ink3)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const BabiIcon('check', size: 14, color: AppColors.green),
                  const SizedBox(width: 6),
                  Text(widget.t.arrived.toUpperCase(),
                      style: AppTheme.manrope(size: 13, weight: FontWeight.w700, color: AppColors.green, letterSpacing: 0.8)),
                ],
              ),
              const SizedBox(height: 6),
              Text(widget.t.thanks,
                  style: AppTheme.manrope(size: 28, weight: FontWeight.w800, height: 1.15, letterSpacing: -0.56)),
              const SizedBox(height: 22),
              _receipt(),
              const SizedBox(height: 18),
              _rateCard(),
              const SizedBox(height: 18),
              CtaButton(
                orange: true,
                enabled: _stars > 0,
                onTap: _stars > 0 ? () => widget.onDone(_stars, _tip) : null,
                child: Text(_stars == 0 ? widget.t.rate : widget.t.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receipt() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: kCardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.t.trip.toUpperCase(),
                  style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.72)),
              Text('$_dist · ${widget.durationMinutes} min',
                  style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.72)),
            ],
          ),
          const SizedBox(height: 10),
          _routeRow(AppColors.green, false, widget.pickupName),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              height: 12,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.line2, width: 2)),
              ),
            ),
          ),
          _routeRow(AppColors.ink, true, widget.destName),
          _divider(14),
          _receiptRow(widget.t.baseFare, fcfaShort(widget.baseFare)),
          if (widget.airportFee > 0) _receiptRow(widget.t.airportFee, fcfaShort(widget.airportFee)),
          if (_tip > 0) _receiptRow(widget.t.tipDriver, fcfaShort(_tip)),
          _divider(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.t.total, style: AppTheme.manrope(size: 15, weight: FontWeight.w800)),
              Text('${groupThousands(_total)} F', style: AppTheme.numeric(size: 22, weight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          Text('${widget.t.paidWith} ${_paymentLabel().toLowerCase()}',
              style: AppTheme.manrope(size: 12, weight: FontWeight.w600, color: AppColors.ink3)),
        ],
      ),
    );
  }

  Widget _routeRow(Color dot, bool square, String label) {
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
              maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.manrope(size: 14, weight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _divider(double v) => Padding(
        padding: EdgeInsets.symmetric(vertical: v),
        child: Container(height: 1, color: AppColors.line),
      );

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.manrope(size: 13, weight: FontWeight.w500, color: AppColors.ink2)),
          Text(value, style: AppTheme.numeric(size: 13, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _rateCard() {
    final d = widget.driver;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: kCardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
                    style: AppTheme.manrope(size: 18, weight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.t.rateSub, style: AppTheme.manrope(size: 12, weight: FontWeight.w600, color: AppColors.ink3)),
                    Text(d.name, style: AppTheme.manrope(size: 16, weight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _stars;
              return Pressable(
                onTap: () => setState(() => _stars = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: BabiIcon('star',
                          size: 32, strokeWidth: 1.5, color: filled ? AppColors.orange : AppColors.line2),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Text(widget.t.tipDriver.toUpperCase(),
              style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.72)),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final v in const [0, 200, 500, 1000]) ...[
                Expanded(
                  child: BabiChip(
                    label: v == 0 ? widget.t.noTip : '+${v}F',
                    expand: true,
                    active: _tip == v,
                    background: _tip == v ? AppColors.ink : AppColors.paper2,
                    foreground: _tip == v ? Colors.white : AppColors.ink2,
                    onTap: () => setState(() => _tip = v),
                  ),
                ),
                if (v != 1000) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
