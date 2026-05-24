import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/saved_place.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/babi_icon.dart';
import '../../widgets/common.dart';
import 'add_saved_place_screen.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().loadSavedPlaces());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.t;
    final places = app.savedPlaces;

    return AccountScaffold(
      title: t.saved,
      actions: [
        Pressable(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddSavedPlaceScreen())),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const BabiIcon('plus', size: 20, color: Colors.white),
          ),
        ),
      ],
      child: places.isEmpty
          ? _empty(t.noSavedPlaces)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _row(context, app, places[i]),
            ),
    );
  }

  Widget _row(BuildContext context, AppState app, SavedPlace p) {
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
            child: BabiIcon(p.icon, size: 18, color: AppColors.ink2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.label, style: AppTheme.manrope(size: 15, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(p.subtitle?.isNotEmpty == true ? p.subtitle! : p.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.manrope(size: 12, color: AppColors.ink3)),
              ],
            ),
          ),
          Pressable(
            onTap: () => app.removeSavedPlace(p),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: BabiIcon('trash', size: 18, color: AppColors.rose),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String label) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(label, style: AppTheme.manrope(color: AppColors.ink3)),
        ),
      );
}
