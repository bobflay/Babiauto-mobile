import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../i18n/strings.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/common.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _initial;
  late Lang _lang;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    final user = app.user;
    _name = TextEditingController(text: user?.name ?? app.riderName);
    _phone = TextEditingController(text: user?.phone ?? '');
    _initial = TextEditingController(text: user?.initial ?? app.riderName[0].toUpperCase());
    _lang = app.lang;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _initial.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final app = context.read<AppState>();
    setState(() => _saving = true);
    await app.updateProfile(
      name: _name.text.trim().isEmpty ? null : _name.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      avatarInitial: _initial.text.trim().isEmpty ? null : _initial.text.trim().toUpperCase(),
      language: _lang,
    );
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final t = app.t;
    return AccountScaffold(
      title: t.editProfile,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(t.fullName, _name),
          _field(t.phone, _phone, keyboard: TextInputType.phone),
          _field(t.initials, _initial, maxLength: 2),
          if ((app.user?.email ?? '').isNotEmpty) _readonly(t.email, app.user!.email),
          const SizedBox(height: 6),
          Text(t.language.toUpperCase(),
              style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.7)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _langChip('Français', Lang.fr)),
              const SizedBox(width: 8),
              Expanded(child: _langChip('English', Lang.en)),
            ],
          ),
          const SizedBox(height: 24),
          CtaButton(
            orange: true,
            enabled: !_saving,
            onTap: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(t.save),
          ),
        ],
      ),
    );
  }

  Widget _langChip(String label, Lang lang) {
    final active = _lang == lang;
    return Pressable(
      onTap: () => setState(() => _lang = lang),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.paper2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: AppTheme.manrope(size: 14, weight: FontWeight.w700, color: active ? Colors.white : AppColors.ink2)),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {TextInputType? keyboard, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.7)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: keyboard,
            maxLength: maxLength,
            cursorColor: AppColors.orange,
            style: AppTheme.manrope(size: 16, weight: FontWeight.w600),
            inputFormatters: maxLength != null ? [LengthLimitingTextInputFormatter(maxLength)] : null,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readonly(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.7)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(14)),
            child: Text(value, style: AppTheme.manrope(size: 16, weight: FontWeight.w600, color: AppColors.ink3)),
          ),
        ],
      ),
    );
  }
}
