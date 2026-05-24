import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'babi_icon.dart';

/// Card / sheet shadows ported from `styles.css`.
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0x1A1A1612), blurRadius: 24, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x0F1A1612), blurRadius: 2, offset: Offset(0, 1)),
];

const List<BoxShadow> kSheetShadow = [
  BoxShadow(color: Color(0x1F1A1612), blurRadius: 32, offset: Offset(0, -8)),
];

/// Tap-to-scale wrapper mimicking the prototype's `button:active { scale(.985) }`.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.97});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  void _set(bool v) {
    if (widget.onTap == null) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Primary CTA — `.cta` / `.cta.orange`.
class CtaButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool orange;
  final double height;
  final bool enabled;
  const CtaButton({
    super.key,
    required this.child,
    this.onTap,
    this.orange = false,
    this.height = 56,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = !enabled
        ? AppColors.ink3.withValues(alpha: 0.5)
        : (orange ? AppColors.orange : AppColors.ink);
    return Pressable(
      onTap: enabled ? onTap : null,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? const [BoxShadow(color: Color(0x381A1612), blurRadius: 18, offset: Offset(0, 6))]
              : null,
        ),
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: AppTheme.manrope(size: 17, weight: FontWeight.w700, color: Colors.white, letterSpacing: 0.17),
          child: child,
        ),
      ),
    );
  }
}

/// Secondary CTA with the paper-2 neutral fill (e.g. the Finding cancel button).
class NeutralButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;
  final Color? foreground;
  const NeutralButton({super.key, required this.label, this.onTap, this.height = 50, this.foreground});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.center,
        child: Text(label,
            style: AppTheme.manrope(size: 16, weight: FontWeight.w700, color: foreground ?? AppColors.ink)),
      ),
    );
  }
}

/// `.chip` pill. `active` swaps to the ink fill.
class BabiChip extends StatelessWidget {
  final String? label;
  final String? icon;
  final bool active;
  final VoidCallback? onTap;
  final double height;
  final bool expand;
  final Color? background;
  final Color? foreground;
  final double fontSize;
  const BabiChip({
    super.key,
    this.label,
    this.icon,
    this.active = false,
    this.onTap,
    this.height = 34,
    this.expand = false,
    this.background,
    this.foreground,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? (active ? Colors.white : AppColors.ink2);
    final bg = background ?? (active ? AppColors.ink : AppColors.inkA(0.05));
    final content = Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            BabiIcon(icon!, size: fontSize, color: fg),
            if (label != null) const SizedBox(width: 6),
          ],
          if (label != null)
            Text(label!, style: AppTheme.manrope(size: fontSize, weight: FontWeight.w600, color: fg)),
        ],
      ),
    );
    return Pressable(onTap: onTap, child: content);
  }
}

/// Floating round map control — `FloatBtn`.
class FloatButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool dark;
  final bool big;
  const FloatButton({super.key, required this.child, this.onTap, this.dark = false, this.big = false});

  @override
  Widget build(BuildContext context) {
    final s = big ? 52.0 : 44.0;
    return Pressable(
      onTap: onTap,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: dark ? const Color(0xD9262019) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: dark ? AppColors.whiteA(0.08) : AppColors.inkA(0.06)),
          boxShadow: const [BoxShadow(color: Color(0x291A1612), blurRadius: 14, offset: Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

/// The sliding `.bottom-sheet` with rounded top + grab handle.
class BottomSheetCard extends StatelessWidget {
  final Widget child;
  final bool animate;
  const BottomSheetCard({super.key, required this.child, this.animate = true});

  @override
  Widget build(BuildContext context) {
    final sheet = Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: kSheetShadow,
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: child,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.inkA(0.16),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (!animate) return SafeArea(top: false, child: sheet);
    return SafeArea(top: false, child: _SlideUp(child: sheet));
  }
}

class _SlideUp extends StatefulWidget {
  final Widget child;
  const _SlideUp({required this.child});
  @override
  State<_SlideUp> createState() => _SlideUpState();
}

class _SlideUpState extends State<_SlideUp> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: const Cubic(0.16, 1, 0.3, 1));
    return SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curve),
      child: FadeTransition(opacity: _c, child: widget.child),
    );
  }
}

/// Small stat tile used on the Finding screen.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  const StatTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: AppTheme.manrope(size: 10, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.6)),
            const SizedBox(height: 2),
            Text(value, style: AppTheme.numeric(size: 15, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Round message/call button — `CircleBtn`.
class CircleButton extends StatelessWidget {
  final String icon;
  final bool primary;
  final VoidCallback? onTap;
  const CircleButton({super.key, required this.icon, this.primary = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primary ? AppColors.green : Colors.white,
          shape: BoxShape.circle,
          border: primary ? null : Border.all(color: AppColors.line),
          boxShadow: primary
              ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]
              : const [BoxShadow(color: Color(0x141A1612), blurRadius: 8, offset: Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: BabiIcon(icon, size: 20, color: primary ? Colors.white : AppColors.ink),
      ),
    );
  }
}
