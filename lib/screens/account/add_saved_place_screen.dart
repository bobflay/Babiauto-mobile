import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/place.dart';
import '../../models/saved_place.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/babi_icon.dart';
import '../../widgets/common.dart';

class AddSavedPlaceScreen extends StatefulWidget {
  const AddSavedPlaceScreen({super.key});

  @override
  State<AddSavedPlaceScreen> createState() => _AddSavedPlaceScreenState();
}

class _AddSavedPlaceScreenState extends State<AddSavedPlaceScreen> {
  final _label = TextEditingController();
  final _search = TextEditingController();
  Timer? _debounce;
  List<Place> _results = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run(''));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _label.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _run(q));
  }

  Future<void> _run(String q) async {
    final r = await context.read<AppState>().searchPlaces(q);
    if (mounted) setState(() => _results = r);
  }

  static String _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('maison') || l.contains('home')) return 'home';
    if (l.contains('bureau') || l.contains('work')) return 'work';
    return 'star';
  }

  Future<void> _save(Place place) async {
    final label = _label.text.trim().isEmpty ? place.name : _label.text.trim();
    await context.read<AppState>().addSavedPlace(SavedPlace(
          label: label,
          icon: _iconFor(label),
          name: place.name,
          subtitle: place.subtitle,
          lat: place.lat,
          lng: place.lng,
        ));
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    return AccountScaffold(
      title: t.addPlace,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _input(_label, t.label, hint: 'Maison, Bureau…'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _quick('Maison', 'home'),
                    const SizedBox(width: 8),
                    _quick('Bureau', 'work'),
                  ],
                ),
                const SizedBox(height: 12),
                _input(_search, t.destination, hint: 'Hôtel, lieu, adresse…', onChanged: _onSearch, search: true),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final p = _results[i];
                return Pressable(
                  onTap: () => _save(p),
                  child: Container(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.line))),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: BabiIcon(p.icon, size: 18, color: AppColors.ink2),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.manrope(size: 15, weight: FontWeight.w700)),
                              if (p.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(p.subtitle, style: AppTheme.manrope(size: 12, color: AppColors.ink3)),
                              ],
                            ],
                          ),
                        ),
                        const BabiIcon('plus', size: 18, color: AppColors.ink3),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _quick(String label, String icon) {
    return BabiChip(label: label, icon: icon, onTap: () => setState(() => _label.text = label));
  }

  Widget _input(TextEditingController c, String label, {String? hint, ValueChanged<String>? onChanged, bool search = false}) {
    return TextField(
      controller: c,
      onChanged: onChanged,
      cursorColor: AppColors.orange,
      style: AppTheme.manrope(size: 16, weight: FontWeight.w600),
      decoration: InputDecoration(
        prefixIcon: search ? const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: BabiIcon('search', size: 20, color: AppColors.ink3)) : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        labelText: label,
        labelStyle: AppTheme.manrope(size: 13, color: AppColors.ink3),
        hintText: hint,
        hintStyle: AppTheme.manrope(size: 16, weight: FontWeight.w500, color: AppColors.ink3),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.orange, width: 1.5)),
      ),
    );
  }
}
