import 'dart:async';

import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../models/place.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/babi_icon.dart';
import '../widgets/common.dart';

class SearchScreen extends StatefulWidget {
  final Strings t;
  final VoidCallback onBack;
  final ValueChanged<Place> onPick;
  final Future<List<Place>> Function(String query) search;

  const SearchScreen({
    super.key,
    required this.t,
    required this.onBack,
    required this.onPick,
    required this.search,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Place> _results = [];
  int _activeChip = 0;

  @override
  void initState() {
    super.initState();
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _runSearch(q));
  }

  Future<void> _runSearch(String q) async {
    final r = await widget.search(q);
    if (mounted) setState(() => _results = r);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paper,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Pressable(
                        onTap: widget.onBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(color: AppColors.paper2, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const BabiIcon('chevronL', size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(widget.t.whereTo, style: AppTheme.manrope(size: 18, weight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _fromTo(),
                  const SizedBox(height: 14),
                  _chips(),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Expanded(child: _resultsList()),
          ],
        ),
      ),
    );
  }

  Widget _fromTo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
        boxShadow: kCardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _FromToRow(
            label: widget.t.pickup,
            value: 'Cocody · Riviera Golf',
            dotColor: AppColors.green,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Container(height: 1, color: AppColors.line),
          ),
          _FromToRow(
            label: widget.t.destination,
            dotColor: AppColors.ink,
            square: true,
            controller: _controller,
            placeholder: 'Hôtel, lieu, adresse…',
            onChanged: _onChanged,
            autofocus: true,
          ),
        ],
      ),
    );
  }

  Widget _chips() {
    final labels = ['Favoris', widget.t.recent, 'Aéroports', 'Centres'];
    final icons = ['star', 'clock', 'plane', 'shop'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => BabiChip(
          label: labels[i],
          icon: icons[i],
          active: _activeChip == i,
          onTap: () => setState(() => _activeChip = i),
        ),
      ),
    );
  }

  Widget _resultsList() {
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(widget.t.noResults, style: AppTheme.manrope(color: AppColors.ink3)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final p = _results[i];
        return Pressable(
          onTap: () => widget.onPick(p),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
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
                      Text(p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.manrope(size: 15, weight: FontWeight.w700)),
                      if (p.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(p.subtitle, style: AppTheme.manrope(size: 12, color: AppColors.ink3)),
                      ],
                    ],
                  ),
                ),
                const BabiIcon('arrowU', size: 16, color: AppColors.ink3),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FromToRow extends StatelessWidget {
  final String label;
  final String? value;
  final Color dotColor;
  final bool square;
  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const _FromToRow({
    required this.label,
    required this.dotColor,
    this.value,
    this.square = false,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          square
              ? Container(width: 12, height: 12, color: dotColor)
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.2), blurRadius: 0, spreadRadius: 3)],
                  ),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: AppTheme.manrope(
                        size: 11, weight: FontWeight.w600, color: AppColors.ink3, letterSpacing: 0.88)),
                const SizedBox(height: 2),
                if (controller != null)
                  TextField(
                    controller: controller,
                    autofocus: autofocus,
                    onChanged: onChanged,
                    style: AppTheme.manrope(size: 16, weight: FontWeight.w600),
                    cursorColor: AppColors.orange,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: placeholder,
                      hintStyle: AppTheme.manrope(size: 16, weight: FontWeight.w500, color: AppColors.ink3),
                    ),
                  )
                else
                  Text(value ?? '', style: AppTheme.manrope(size: 16, weight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
