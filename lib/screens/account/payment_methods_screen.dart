import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/strings.dart';
import '../../models/payment_method.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/babi_icon.dart';
import '../../widgets/common.dart';
import 'add_payment_method_screen.dart';

String paymentDisplay(PaymentMethod m, Strings t) {
  switch (m.type) {
    case 'cash':
      return t.payCash;
    case 'mobile':
      return m.provider?.isNotEmpty == true ? '${t.payMobile} · ${m.provider}' : t.payMobile;
    case 'card':
      return m.last4?.isNotEmpty == true ? '${t.payCard} · •• ${m.last4}' : t.payCard;
    default:
      return m.label;
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().loadPaymentMethods());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.t;
    final methods = app.paymentMethods;

    return AccountScaffold(
      title: t.paymentMethod,
      actions: [
        Pressable(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddPaymentMethodScreen())),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const BabiIcon('plus', size: 20, color: Colors.white),
          ),
        ),
      ],
      child: methods.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(t.noPayments, style: AppTheme.manrope(color: AppColors.ink3))))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: methods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _row(app, t, methods[i]),
            ),
    );
  }

  Widget _row(AppState app, Strings t, PaymentMethod m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: BabiIcon(m.type, size: 18, color: AppColors.ink2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(child: Text(paymentDisplay(m, t), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.manrope(size: 15, weight: FontWeight.w700))),
                if (m.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.orangeSoft, borderRadius: BorderRadius.circular(6)),
                    child: Text(t.defaultLabel,
                        style: AppTheme.manrope(size: 10, weight: FontWeight.w700, color: AppColors.orangeDeep)),
                  ),
                ],
              ],
            ),
          ),
          Pressable(
            onTap: () => app.removePaymentMethod(m),
            child: const Padding(padding: EdgeInsets.all(6), child: BabiIcon('trash', size: 18, color: AppColors.rose)),
          ),
        ],
      ),
    );
  }
}
