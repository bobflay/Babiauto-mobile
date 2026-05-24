import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/babi_map.dart';

/// On phones the app fills the screen. On wide layouts (web / desktop) it is
/// centred in a phone-sized frame against the prototype's warm dark backdrop.
class DeviceFrame extends StatelessWidget {
  final Widget child;
  const DeviceFrame({super.key, required this.child});

  static const double _breakpoint = 520;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _breakpoint;
        if (!wide) {
          return ClipRect(child: child);
        }

        final maxH = constraints.maxHeight - 48;
        final h = maxH < kMapH ? maxH : kMapH;
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.4, -0.8),
              radius: 1.4,
              colors: [Color(0x1AF39423), Color(0xFF1F1B17)],
              stops: [0.0, 0.6],
            ),
            color: Color(0xFF1F1B17),
          ),
          alignment: Alignment.center,
          child: Container(
            width: kMapW,
            height: h,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(44),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 60, offset: Offset(0, 30)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery(
              // Inside the frame there is no hardware notch / inset.
              data: MediaQuery.of(context).removePadding(
                removeTop: true,
                removeBottom: true,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
