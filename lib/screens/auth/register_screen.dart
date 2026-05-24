import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/common.dart';
import 'auth_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<AppState>().register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          phone: _phone.text,
        );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    return AccountScaffold(
      title: t.createAccount,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.welcome, style: AppTheme.manrope(size: 26, weight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(t.tagline, style: AppTheme.manrope(size: 14, color: AppColors.ink3)),
          const SizedBox(height: 22),
          AuthField(label: t.fullName, controller: _name),
          AuthField(label: t.email, controller: _email, keyboard: TextInputType.emailAddress),
          AuthField(label: '${t.phone} (${t.optional})', controller: _phone, keyboard: TextInputType.phone),
          AuthField(label: t.password, controller: _password, obscure: true),
          if (_error != null) ...[
            const SizedBox(height: 4),
            Text(_error!, style: AppTheme.manrope(size: 13, weight: FontWeight.w600, color: AppColors.rose)),
          ],
          const SizedBox(height: 18),
          CtaButton(
            orange: true,
            enabled: !_busy,
            onTap: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(t.createAccount),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.haveAccount, style: AppTheme.manrope(size: 13, color: AppColors.ink3)),
              const SizedBox(width: 6),
              Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: Text(t.signIn,
                    style: AppTheme.manrope(size: 13, weight: FontWeight.w700, color: AppColors.orangeDeep)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
