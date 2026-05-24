import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_config.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/common.dart';
import 'auth_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await context.read<AppState>().login(_email.text, _password.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  Future<void> _openRegister() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (ok == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<AppState>().t;
    return AccountScaffold(
      title: t.signIn,
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.welcomeBack, style: AppTheme.manrope(size: 26, weight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(t.signInPrompt, style: AppTheme.manrope(size: 14, color: AppColors.ink3)),
          const SizedBox(height: 22),
          AuthField(label: t.email, controller: _email, keyboard: TextInputType.emailAddress),
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
                : Text(t.signIn),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.paper2, borderRadius: BorderRadius.circular(12)),
            child: Text('${t.demoCredentials} · ${ApiConfig.demoEmail} / ${ApiConfig.demoPassword}',
                textAlign: TextAlign.center,
                style: AppTheme.manrope(size: 12, weight: FontWeight.w600, color: AppColors.ink3)),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.noAccount, style: AppTheme.manrope(size: 13, color: AppColors.ink3)),
              const SizedBox(width: 6),
              Pressable(
                onTap: _openRegister,
                child: Text(t.createAccount,
                    style: AppTheme.manrope(size: 13, weight: FontWeight.w700, color: AppColors.orangeDeep)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
