import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../i18n/strings.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/common.dart';
import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';
import 'ride_history_screen.dart';
import 'saved_places_screen.dart';

const avatarGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF39423), Color(0xFFC75F00)],
);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.t;
    final user = app.user;
    final initial = user?.initial ?? app.riderName[0].toUpperCase();
    final name = user?.name ?? app.riderName;

    return AccountScaffold(
      title: t.profile,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(t, initial, name, user?.email, user?.phone, user?.createdAt?.year),
          const SizedBox(height: 18),
          MenuRow(icon: 'edit', label: t.editProfile, onTap: () => _push(context, const EditProfileScreen())),
          const SizedBox(height: 10),
          MenuRow(
            icon: 'star',
            label: t.saved,
            value: '${app.savedPlaces.isEmpty ? '' : app.savedPlaces.length}',
            onTap: () => _push(context, const SavedPlacesScreen()),
          ),
          const SizedBox(height: 10),
          MenuRow(icon: 'card', label: t.paymentMethod, onTap: () => _push(context, const PaymentMethodsScreen())),
          const SizedBox(height: 10),
          MenuRow(icon: 'clock', label: t.rideHistory, onTap: () => _push(context, const RideHistoryScreen())),
          const SizedBox(height: 10),
          _languageRow(context, app, t),
          const SizedBox(height: 18),
          MenuRow(
            icon: 'logout',
            label: t.logout,
            tint: AppColors.rose,
            trailing: const SizedBox.shrink(),
            onTap: () async {
              await app.logout();
              if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
            },
          ),
          const SizedBox(height: 12),
          if (!app.online)
            Center(
              child: Text(t.demoMode,
                  style: AppTheme.manrope(size: 12, weight: FontWeight.w600, color: AppColors.ink3)),
            ),
        ],
      ),
    );
  }

  Widget _header(Strings t, String initial, String name, String? email, String? phone, int? year) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: kCardShadow),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(gradient: avatarGradient, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initial, style: AppTheme.manrope(size: 26, weight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.manrope(size: 20, weight: FontWeight.w800)),
                if (email != null && email.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.manrope(size: 13, color: AppColors.ink3)),
                ],
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(phone, style: AppTheme.manrope(size: 13, weight: FontWeight.w600, color: AppColors.ink2)),
                ],
                if (year != null) ...[
                  const SizedBox(height: 6),
                  Text('${t.memberSince} $year',
                      style: AppTheme.manrope(size: 11, weight: FontWeight.w700, color: AppColors.orangeDeep, letterSpacing: 0.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageRow(BuildContext context, AppState app, Strings t) {
    Widget seg(String label, Lang lang) {
      final active = app.lang == lang;
      return Pressable(
        onTap: () => app.changeLanguage(lang),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: AppTheme.manrope(
                  size: 12, weight: FontWeight.w700, color: active ? Colors.white : AppColors.ink3)),
        ),
      );
    }

    return MenuRow(
      icon: 'sparkle',
      label: t.language,
      trailing: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [seg('FR', Lang.fr), seg('EN', Lang.en)]),
      ),
    );
  }
}
