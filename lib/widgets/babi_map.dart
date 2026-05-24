import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

const double kMapW = 402;
const double kMapH = 874;

/// Faux-Abidjan map: lagoon, bridges, street grid, neighborhood labels, plus an
/// animated route + car/pickup/drop markers. Ported from the prototype's
/// `map.jsx`. All marker coordinates are in the 402×874 design space.
class BabiMap extends StatefulWidget {
  final bool dark;
  final Offset? pickup;
  final Offset? dropoff;
  final Offset? carPos;
  final double carRotation;
  final bool showRoute;
  final bool showPickup;
  final bool showDropoff;
  final bool showUser;

  const BabiMap({
    super.key,
    this.dark = false,
    this.pickup,
    this.dropoff,
    this.carPos,
    this.carRotation = 0,
    this.showRoute = true,
    this.showPickup = true,
    this.showDropoff = true,
    this.showUser = true,
  });

  @override
  State<BabiMap> createState() => _BabiMapState();
}

class _BabiMapState extends State<BabiMap> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.string(
            _baseMapSvg(widget.dark),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => CustomPaint(
              painter: _MapOverlayPainter(
                dark: widget.dark,
                pickup: widget.pickup,
                dropoff: widget.dropoff,
                carPos: widget.carPos,
                carRotation: widget.carRotation,
                showRoute: widget.showRoute,
                showPickup: widget.showPickup,
                showDropoff: widget.showDropoff,
                showUser: widget.showUser,
                pulse: _pulse.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapOverlayPainter extends CustomPainter {
  final bool dark;
  final Offset? pickup;
  final Offset? dropoff;
  final Offset? carPos;
  final double carRotation;
  final bool showRoute;
  final bool showPickup;
  final bool showDropoff;
  final bool showUser;
  final double pulse;

  _MapOverlayPainter({
    required this.dark,
    required this.pickup,
    required this.dropoff,
    required this.carPos,
    required this.carRotation,
    required this.showRoute,
    required this.showPickup,
    required this.showDropoff,
    required this.showUser,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Same cover transform SvgPicture applies (BoxFit.cover, centered).
    final scale = (size.width / kMapW).clamp(0, double.infinity) > (size.height / kMapH)
        ? size.width / kMapW
        : size.height / kMapH;
    final dx = (size.width - kMapW * scale) / 2;
    final dy = (size.height - kMapH * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, kMapW, kMapH));

    if (showRoute && pickup != null && dropoff != null) {
      _paintRoute(canvas, pickup!, dropoff!);
    }
    if (showPickup && pickup != null) _paintPickupPin(canvas, pickup!);
    if (showDropoff && dropoff != null) _paintDropPin(canvas, dropoff!);
    if (carPos != null) _paintCar(canvas, carPos!, carRotation);
    if (showUser && carPos == null && pickup != null) _paintUserDot(canvas, pickup!);

    canvas.restore();
  }

  void _paintRoute(Canvas canvas, Offset p, Offset d) {
    final midX = (p.dx + d.dx) / 2;
    final midY = (p.dy + d.dy) / 2;
    final viaX = midX < 200 ? 120.0 : 280.0;
    final qc = Offset(viaX, midY - 40);
    final qe = Offset((viaX + d.dx) / 2, midY + 20);
    final tc = Offset(2 * qe.dx - qc.dx, 2 * qe.dy - qc.dy);

    final path = Path()
      ..moveTo(p.dx, p.dy)
      ..quadraticBezierTo(qc.dx, qc.dy, qe.dx, qe.dy)
      ..quadraticBezierTo(tc.dx, tc.dy, d.dx, d.dy);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = (dark ? Colors.black : Colors.white).withValues(alpha: 0.85),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = AppColors.orange,
    );
  }

  void _paintPickupPin(Canvas canvas, Offset o) {
    canvas.drawCircle(o, 10, Paint()..color = Colors.white);
    canvas.drawCircle(
      o,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.15),
    );
    canvas.drawCircle(o, 6, Paint()..color = AppColors.green);
    canvas.drawCircle(o, 2, Paint()..color = Colors.white);
  }

  void _paintDropPin(Canvas canvas, Offset o) {
    final ink = Paint()..color = AppColors.ink;
    canvas.drawLine(
      o,
      o.translate(0, -24),
      Paint()
        ..color = AppColors.ink
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(o.dx, o.dy - 24, 18, 14), const Radius.circular(2)),
      ink,
    );
    canvas.drawCircle(o, 4, ink);
    canvas.drawCircle(o, 2, Paint()..color = Colors.white);
  }

  void _paintUserDot(Canvas canvas, Offset o) {
    final lagoon = AppColors.lagoon;
    canvas.drawCircle(o, 22, Paint()..color = lagoon.withValues(alpha: 0.15));
    // pulsing ring: r 10..22, opacity 0.35..0.05
    final r = 10 + 12 * pulse;
    final op = 0.35 - 0.30 * pulse;
    canvas.drawCircle(o, r, Paint()..color = lagoon.withValues(alpha: op.clamp(0.0, 1.0)));
    canvas.drawCircle(o, 7, Paint()..color = lagoon);
    canvas.drawCircle(
      o,
      7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = Colors.white,
    );
  }

  void _paintCar(Canvas canvas, Offset o, double rotationDeg) {
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.rotate(rotationDeg * 3.1415926535 / 180);
    canvas.drawCircle(Offset.zero, 18, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(
      Offset.zero,
      18,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.1),
    );
    canvas.translate(-10, -10);
    final orange = Paint()..color = AppColors.orange;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(2, 7, 16, 7), const Radius.circular(2)), orange);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4, 4, 12, 5), const Radius.circular(1.5)), orange);
    final win = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawRect(const Rect.fromLTWH(6, 5, 3, 3), win);
    canvas.drawRect(const Rect.fromLTWH(11, 5, 3, 3), win);
    final wheel = Paint()..color = AppColors.ink;
    canvas.drawCircle(const Offset(6, 15), 1.8, wheel);
    canvas.drawCircle(const Offset(14, 15), 1.8, wheel);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapOverlayPainter old) =>
      old.pulse != pulse ||
      old.pickup != pickup ||
      old.dropoff != dropoff ||
      old.carPos != carPos ||
      old.carRotation != carRotation ||
      old.dark != dark ||
      old.showRoute != showRoute ||
      old.showUser != showUser;
}

// ─────────────────────────────────────────────────────────────────────────────
// Static base map, ported from map.jsx (lagoon, parks, streets, labels, blocks).
// ─────────────────────────────────────────────────────────────────────────────

const String _lagoonPath =
    'M -20 380 C 40 360, 90 410, 140 400 C 190 390, 220 360, 260 380 C 300 400, 330 430, 380 420 '
    'C 410 415, 440 400, 440 420 L 440 560 C 400 570, 360 555, 320 570 C 280 585, 250 600, 200 590 '
    'C 150 580, 110 560, 70 575 C 30 590, -10 580, -20 580 Z';

const List<String> _parks = [
  'M 260 60 C 290 50, 340 60, 360 90 C 380 120, 360 160, 320 170 C 280 180, 250 150, 240 120 C 230 90, 240 70, 260 60 Z',
  'M 30 700 C 60 690, 100 700, 110 730 C 120 760, 90 790, 60 780 C 30 770, 10 740, 30 700 Z',
];

const List<String> _streets = [
  'M 0 120 L 402 120', 'M 0 180 L 402 180', 'M 0 240 L 402 240', 'M 0 300 L 402 300',
  'M 80 40 L 80 380', 'M 160 40 L 160 380', 'M 240 40 L 240 380', 'M 320 40 L 320 380',
  'M 110 380 L 130 580', 'M 290 380 L 270 580',
  'M 0 620 L 402 620', 'M 0 680 L 402 680', 'M 0 740 L 402 740', 'M 0 800 L 402 800',
  'M 60 580 L 60 874', 'M 140 580 L 140 874', 'M 220 580 L 220 874', 'M 300 580 L 300 874', 'M 380 580 L 380 874',
];

const List<String> _minorStreets = [
  'M 0 60 L 402 60', 'M 0 90 L 402 90', 'M 0 150 L 402 150', 'M 0 210 L 402 210', 'M 0 270 L 402 270', 'M 0 340 L 402 340',
  'M 40 40 L 40 380', 'M 120 40 L 120 380', 'M 200 40 L 200 380', 'M 280 40 L 280 380', 'M 360 40 L 360 380',
  'M 0 650 L 402 650', 'M 0 710 L 402 710', 'M 0 770 L 402 770', 'M 0 830 L 402 830',
  'M 100 580 L 100 874', 'M 180 580 L 180 874', 'M 260 580 L 260 874', 'M 340 580 L 340 874',
];

const List<List<dynamic>> _labels = [
  [200, 110, 'PLATEAU', 11, false],
  [320, 220, 'COCODY', 11, false],
  [70, 220, 'ATTÉCOUBÉ', 9, false],
  [80, 720, 'YOPOUGON', 11, false],
  [260, 700, 'TREICHVILLE', 11, false],
  [340, 820, 'MARCORY', 10, false],
  [200, 480, 'lagune ébrié', 9, true],
];

String _baseMapSvg(bool dark) {
  final c = dark
      ? const {
          'land': '#1F1B17', 'land2': '#28231E', 'water': '#0F2433', 'waterEdge': '#1B3A50',
          'street': '#3A332D', 'streetMinor': '#2E2925', 'streetStroke': '#544A40', 'park': '#1A2B1F',
          'label': 'rgba(255,255,255,0.55)', 'labelWater': 'rgba(160,200,230,0.55)', 'block': 'rgba(255,255,255,0.05)',
        }
      : const {
          'land': '#F4EEDF', 'land2': '#EBE3D0', 'water': '#CFE3EE', 'waterEdge': '#B8D4E1',
          'street': '#FFFFFF', 'streetMinor': '#FBF7EE', 'streetStroke': '#E5DCC7', 'park': '#D5E5C0',
          'label': 'rgba(40,32,22,0.55)', 'labelWater': 'rgba(40,90,130,0.55)', 'block': 'rgba(26,22,18,0.06)',
        };

  final b = StringBuffer()
    ..write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $kMapW $kMapH" '
        'width="$kMapW" height="$kMapH">')
    ..write('<rect x="0" y="0" width="$kMapW" height="$kMapH" fill="${c['land']}"/>')
    ..write('<rect x="0" y="0" width="$kMapW" height="380" fill="${c['land2']}" opacity="0.4"/>')
    ..write('<path d="$_lagoonPath" fill="${c['water']}"/>')
    ..write('<path d="$_lagoonPath" fill="none" stroke="${c['waterEdge']}" stroke-width="1.5"/>')
    // ripples
    ..write('<g stroke="${c['waterEdge']}" stroke-width="0.6" fill="none" opacity="0.6">')
    ..write('<path d="M 30 450 C 80 445, 130 455, 180 450 C 230 445, 280 455, 330 450"/>')
    ..write('<path d="M 60 490 C 110 485, 160 495, 210 490 C 260 485, 310 495, 360 490"/>')
    ..write('<path d="M 30 530 C 80 525, 130 535, 180 530 C 230 525, 280 535, 330 530"/></g>');

  for (final p in _parks) {
    b.write('<path d="$p" fill="${c['park']}"/>');
  }

  b.write('<g stroke="${c['streetMinor']}" stroke-width="3" stroke-linecap="round" fill="none">');
  for (final d in _minorStreets) {
    b.write('<path d="$d"/>');
  }
  b.write('</g>');

  b.write('<g stroke="${c['streetStroke']}" stroke-width="9" stroke-linecap="round" fill="none">');
  for (final d in _streets) {
    b.write('<path d="$d"/>');
  }
  b.write('</g>');
  b.write('<g stroke="${c['street']}" stroke-width="7" stroke-linecap="round" fill="none">');
  for (final d in _streets) {
    b.write('<path d="$d"/>');
  }
  b.write('</g>');

  // block detail dots
  b.write('<g fill="${c['block']}">');
  for (var i = 0; i < 40; i++) {
    final x = (i * 53) % 380 + 12;
    final y = (i * 71) % 280 + 30;
    b.write('<rect x="$x" y="$y" width="22" height="14" rx="2"/>');
  }
  for (var i = 0; i < 40; i++) {
    final x = (i * 47) % 380 + 12;
    final y = (i * 67) % 240 + 600;
    b.write('<rect x="$x" y="$y" width="20" height="13" rx="2"/>');
  }
  b.write('</g>');

  // bridge labels
  b.write('<g font-family="Manrope, system-ui" font-size="7" fill="${c['labelWater']}" font-weight="600">');
  b.write('<text x="60" y="480" transform="rotate(75, 60, 480)">PONT H.-BOIGNY</text>');
  b.write('<text x="340" y="480" transform="rotate(-75, 340, 480)">PONT DE GAULLE</text></g>');

  // neighborhood labels
  for (final l in _labels) {
    final name = l[2] as String;
    final size = l[3];
    final italic = l[4] as bool;
    b.write('<text x="${l[0]}" y="${l[1]}" font-family="Manrope, system-ui" '
        'font-size="$size" fill="${italic ? c['labelWater'] : c['label']}" '
        'font-weight="${italic ? 500 : 700}" font-style="${italic ? 'italic' : 'normal'}" '
        'letter-spacing="1.2" text-anchor="middle">$name</text>');
  }

  b.write('</svg>');
  return b.toString();
}
