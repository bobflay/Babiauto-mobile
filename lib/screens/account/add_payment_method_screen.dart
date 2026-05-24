import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/payment_method.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/babi_icon.dart';
import '../../widgets/common.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  String _type = 'mobile';
  bool _default = false;
  final _provider = TextEditingController();
  final _last4 = TextEditingController();

  @override
  void dispose() {
    _provider.dispose();
    _last4.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final app = context.read<AppState>();
    await app.addPaymentMethod(PaymentMethod(
      type: _type,
      provider: _type == 'cash' || _provider.text.trim().isEmpty ? null : _provider.text.trim(),
      last4: _type == 'card' && _last4.text.trim().length == 4 ? _last4.text.trim() : null,
      isDefault: _default,
    ));
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    final labels = {'cash': t.payCash, 'mobile': t.payMobile, 'card': t.payCard};
    return AccountScaffold(
      title: t.addPayment,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final type in const ['cash', 'mobile', 'card']) ...[
                Expanded(child: _typeTile(type, labels[type]!)),
                if (type != 'card') const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 18),
          if (_type != 'cash') _field(t.provider, _provider, hint: _type == 'mobile' ? 'Orange, MTN, Moov…' : 'Visa, Mastercard…'),
          if (_type == 'card') _field(t.cardLast4, _last4, keyboard: TextInputType.number, maxLength: 4),
          Pressable(
            onTap: () => setState(() => _default = !_default),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
              child: Row(
                children: [
                  Expanded(child: Text(t.setDefault, style: AppTheme.manrope(size: 15, weight: FontWeight.w600))),
                  Switch(value: _default, activeThumbColor: AppColors.orange, onChanged: (v) => setState(() => _default = v)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CtaButton(orange: true, onTap: _save, child: Text(t.save)),
        ],
      ),
    );
  }

  Widget _typeTile(String type, String label) {
    final active = _type == type;
    return Pressable(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.paper2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            BabiIcon(type, size: 22, color: active ? Colors.white : AppColors.ink2),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: active ? Colors.white : AppColors.ink2)),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {String? hint, TextInputType? keyboard, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.7)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: keyboard,
            maxLength: maxLength,
            cursorColor: AppColors.orange,
            style: AppTheme.manrope(size: 16, weight: FontWeight.w600),
            inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength), FilteringTextInputFormatter.digitsOnly] : null,
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: AppTheme.manrope(size: 16, weight: FontWeight.w500, color: AppColors.ink3),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.orange, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
