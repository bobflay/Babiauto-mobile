import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'babi_icon.dart';
import 'common.dart';

/// Floating menu + profile avatar over the map (`MapTopBar`).
class MapTopBar extends StatelessWidget {
  final bool dark;
  final String initial;
  final VoidCallback? onMenu;
  final VoidCallback? onProfile;
  const MapTopBar({
    super.key,
    this.dark = false,
    this.initial = 'K',
    this.onMenu,
    this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = dark ? Colors.white : AppColors.ink;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatButton(
              dark: dark,
              onTap: onMenu,
              child: BabiIcon('menu', size: 20, color: iconColor),
            ),
            FloatButton(
              dark: dark,
              onTap: onProfile,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(initial,
                    style: AppTheme.manrope(size: 13, weight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
