import 'dart:async';

import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Strings t;
  final VoidCallback onNext;
  const SplashScreen({super.key, required this.t, required this.onNext});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat(reverse: true);
  late final AnimationController _track = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    _auto = Timer(const Duration(milliseconds: 6000), widget.onNext);
  }

  @override
  void dispose() {
    _auto?.cancel();
    _float.dispose();
    _track.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _auto?.cancel();
        widget.onNext();
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 1.3,
            colors: [Color(0xFF2A211A), Color(0xFF1A1410), Color(0xFF0F0C0A)],
            stops: [0, 0.55, 1],
          ),
        ),
        child: Stack(
          children: [
            // warm glows
            const Positioned(
              top: 80,
              left: -120,
              child: _Glow(size: 640, color: Color(0x6BF39423)),
            ),
            const Positioned(
              bottom: 40,
              left: -80,
              child: _Glow(size: 380, color: Color(0x38FF5A00)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 44, 28, 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _topRow(),
                    Expanded(child: _logo()),
                    _loader(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.whiteA(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.whiteA(0.12)),
          ),
          alignment: Alignment.center,
          child: const Text('🇨🇮', style: TextStyle(fontSize: 22)),
        ),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.orange, blurRadius: 8)],
              ),
            ),
            const SizedBox(width: 8),
            Text('V 1.0 · ABIDJAN',
                style: AppTheme.manrope(
                    size: 11, weight: FontWeight.w700, color: AppColors.whiteA(0.65), letterSpacing: 1.3)),
          ],
        ),
      ],
    );
  }

  Widget _logo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) =>
                Transform.translate(offset: Offset(0, -6 * _float.value), child: child),
            child: Image.asset(
              'assets/images/babiauto-logo-transparent.png',
              width: 280,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Text('Babiauto',
                  style: AppTheme.manrope(size: 44, weight: FontWeight.w800, color: AppColors.orange)),
            ),
          ),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              widget.t.tagline,
              textAlign: TextAlign.center,
              style: AppTheme.manrope(
                  size: 17, weight: FontWeight.w500, color: AppColors.whiteA(0.78), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loader() {
    return Column(
      children: [
        // sliding track
        SizedBox(
          width: 240,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              color: AppColors.whiteA(0.10),
              child: AnimatedBuilder(
                animation: _track,
                builder: (context, _) {
                  return LayoutBuilder(builder: (context, c) {
                    final w = c.maxWidth;
                    final x = -0.45 * w + (1.5 * w) * _track.value;
                    return Stack(children: [
                      Positioned(
                        left: x,
                        top: 0,
                        bottom: 0,
                        width: w * 0.4,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0x00F39423),
                              AppColors.orange,
                              Color(0x00F39423),
                            ]),
                          ),
                        ),
                      ),
                    ]);
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _dots,
          builder: (context, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final phase = (_dots.value - i * 0.15) % 1.0;
              final s = phase < 0.4 ? 0.6 + (phase / 0.4) * 0.4 : 1.0 - ((phase - 0.4).clamp(0, 0.6) / 0.6) * 0.4;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.scale(
                  scale: s.clamp(0.6, 1.0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 18),
        Text(widget.t.tapToContinue.toUpperCase(),
            style: AppTheme.manrope(
                size: 12, weight: FontWeight.w600, color: AppColors.whiteA(0.55), letterSpacing: 0.96)),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)], stops: const [0, 0.65]),
        ),
      ),
    );
  }
}
