import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Labeled text field used across the auth screens, with an optional
/// show/hide toggle for password inputs.
class AuthField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final bool obscure;
  final String? hint;

  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboard,
    this.obscure = false,
    this.hint,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label.toUpperCase(),
              style: AppTheme.manrope(size: 12, weight: FontWeight.w700, color: AppColors.ink3, letterSpacing: 0.7)),
          const SizedBox(height: 6),
          TextField(
            controller: widget.controller,
            keyboardType: widget.keyboard,
            obscureText: _hidden,
            cursorColor: AppColors.orange,
            style: AppTheme.manrope(size: 16, weight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTheme.manrope(size: 16, weight: FontWeight.w500, color: AppColors.ink3),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: widget.obscure
                  ? Pressable(
                      onTap: () => setState(() => _hidden = !_hidden),
                      child: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20, color: AppColors.ink3),
                    )
                  : null,
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
}
