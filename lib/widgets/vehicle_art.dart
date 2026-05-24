import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Iconic side-view of each vehicle type, ported from `VehicleArt` in screens.jsx.
class VehicleArt extends StatelessWidget {
  final String slug;
  final bool selected;
  const VehicleArt({super.key, required this.slug, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.whiteA(0.12) : Colors.white;
    final fg = selected ? Colors.white : AppColors.orange;
    return Container(
      width: 64,
      height: 44,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: CustomPaint(painter: _VehiclePainter(slug, fg)),
    );
  }
}

class _VehiclePainter extends CustomPainter {
  final String slug;
  final Color fg;
  _VehiclePainter(this.slug, this.fg);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = fg;
    final thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = fg;
    final wheelFill = Paint()..color = Colors.white;

    void poly(List<Offset> pts) {
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(p, stroke);
    }

    void wheel(Offset c, double r, {bool fill = true}) {
      if (fill) canvas.drawCircle(c, r, wheelFill);
      canvas.drawCircle(c, r, stroke);
    }

    switch (slug) {
      case 'moto':
        canvas.drawCircle(const Offset(14, 32), 6, stroke);
        canvas.drawCircle(const Offset(50, 32), 6, stroke);
        poly(const [Offset(20, 32), Offset(36, 18), Offset(50, 32)]);
        poly(const [Offset(36, 18), Offset(44, 14)]);
        poly(const [Offset(28, 18), Offset(36, 18)]);
        break;
      case 'xl':
        poly(const [Offset(4, 30), Offset(4, 22), Offset(12, 14), Offset(50, 14), Offset(58, 22), Offset(60, 30)]);
        poly(const [Offset(4, 30), Offset(60, 30)]);
        wheel(const Offset(16, 32), 5);
        wheel(const Offset(46, 32), 5);
        for (final x in [14.0, 26.0, 38.0, 50.0]) {
          canvas.drawLine(Offset(x, 14), Offset(x, 22), thin);
        }
        break;
      case 'confort':
        poly(const [Offset(4, 30), Offset(8, 22), Offset(18, 18), Offset(24, 14), Offset(42, 14), Offset(50, 22), Offset(60, 30)]);
        poly(const [Offset(4, 30), Offset(60, 30)]);
        wheel(const Offset(16, 32), 5);
        wheel(const Offset(46, 32), 5);
        canvas.drawLine(const Offset(22, 18), const Offset(32, 14), thin);
        canvas.drawLine(const Offset(32, 14), const Offset(32, 22), thin);
        canvas.drawLine(const Offset(32, 22), const Offset(22, 22), thin);
        break;
      default: // mini
        poly(const [Offset(6, 30), Offset(10, 22), Offset(22, 18), Offset(42, 18), Offset(50, 22), Offset(56, 30)]);
        poly(const [Offset(6, 30), Offset(56, 30)]);
        wheel(const Offset(16, 32), 4.5);
        wheel(const Offset(44, 32), 4.5);
    }
  }

  @override
  bool shouldRepaint(covariant _VehiclePainter old) => old.slug != slug || old.fg != fg;
}
