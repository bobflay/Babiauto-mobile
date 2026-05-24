import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'babi_icon.dart';
import 'common.dart';

/// Consistent header + paper background for account / profile sub-screens.
class AccountScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool scrollable;
  const AccountScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = scrollable
        ? SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), child: child)
        : child;
    return Container(
      color: AppColors.paper,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Pressable(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: AppColors.paper2, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const BabiIcon('chevronL', size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(title, style: AppTheme.manrope(size: 18, weight: FontWeight.w700))),
                  ...actions,
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// Tappable settings-style row used on the profile screen.
class MenuRow extends StatelessWidget {
  final String icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? tint;
  const MenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final color = tint ?? AppColors.ink;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              decoration: BoxDecoration(
                color: tint == null ? AppColors.paper2 : tint!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: BabiIcon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.manrope(size: 15, weight: FontWeight.w700, color: color)),
                  if (value != null && value!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(value!, style: AppTheme.manrope(size: 12, color: AppColors.ink3)),
                  ],
                ],
              ),
            ),
            trailing ?? const BabiIcon('chevron', size: 18, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}
