import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// The prototype's inline-SVG icon set, ported 1:1. Each entry is the inner
/// markup of a 24×24, stroke-based, round-capped line icon.
class BabiIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double strokeWidth;

  const BabiIcon(
    this.name, {
    super.key,
    this.size = 20,
    this.color = AppColors.ink,
    this.strokeWidth = 2,
  });

  static const Map<String, String> _paths = {
    'menu': '<path d="M3 6h18M3 12h18M3 18h12"/>',
    'search': '<circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/>',
    'pin': '<path d="M12 22s7-7.5 7-13a7 7 0 1 0-14 0c0 5.5 7 13 7 13z"/><circle cx="12" cy="9" r="2.5"/>',
    'clock': '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
    'home': '<path d="M3 11l9-7 9 7v9a2 2 0 0 1-2 2h-4v-6h-6v6H5a2 2 0 0 1-2-2v-9z"/>',
    'work': '<rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>',
    'plane': '<path d="M2 16l20-7L17 22l-5-7-7 2-3-1z"/>',
    'star': '<path d="M12 3l2.6 5.5 6 .9-4.3 4.2 1 6L12 16.8l-5.3 2.8 1-6L3.4 9.4l6-.9L12 3z"/>',
    'shop': '<path d="M4 7l1-3h14l1 3M4 7v13h16V7M4 7h16"/><path d="M9 11h6"/>',
    'chevron': '<path d="M9 6l6 6-6 6"/>',
    'chevronL': '<path d="M15 6l-6 6 6 6"/>',
    'chevronD': '<path d="M6 9l6 6 6-6"/>',
    'phone': '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.9 19.9 0 0 1-8.67-3.07 19.5 19.5 0 0 1-6-6 19.9 19.9 0 0 1-3.07-8.7A2 2 0 0 1 4.08 2h3a2 2 0 0 1 2 1.72 12.8 12.8 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.8 12.8 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>',
    'msg': '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>',
    'shield': '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>',
    'share': '<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M8.6 13.5l6.8 4M15.4 6.5l-6.8 4"/>',
    'x': '<path d="M6 6l12 12M18 6L6 18"/>',
    'plus': '<path d="M12 5v14M5 12h14"/>',
    'check': '<path d="M5 12l5 5 9-11"/>',
    'card': '<rect x="2" y="6" width="20" height="14" rx="2"/><path d="M2 11h20"/>',
    'cash': '<rect x="2" y="6" width="20" height="13" rx="2"/><circle cx="12" cy="12.5" r="3"/>',
    'mobile': '<rect x="6" y="2" width="12" height="20" rx="2"/><path d="M11 18h2"/>',
    'arrowR': '<path d="M5 12h14M13 5l7 7-7 7"/>',
    'arrowU': '<path d="M12 19V5M5 12l7-7 7 7"/>',
    'crosshair': '<circle cx="12" cy="12" r="9"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3"/><circle cx="12" cy="12" r="2"/>',
    'sparkle': '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z"/>',
    'user': '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
    'edit': '<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/>',
    'logout': '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/>',
    'trash': '<path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>',
    'receipt': '<path d="M5 3v18l2-1 2 1 2-1 2 1 2-1 2 1V3l-2 1-2-1-2 1-2-1-2 1z"/><path d="M9 8h6M9 12h6"/>',
  };

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  @override
  Widget build(BuildContext context) {
    final inner = _paths[name];
    if (inner == null) return SizedBox(width: size, height: size);
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="$size" height="$size" '
        'fill="none" stroke="${_hex(color)}" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">$inner</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}
