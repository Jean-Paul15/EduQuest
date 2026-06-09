import 'package:eduquest/features/app_config/domain/auth_options.dart';
import 'package:eduquest/features/auth/presentation/login_email_form.dart';
import 'package:eduquest/features/auth/presentation/login_header.dart';
import 'package:eduquest/features/auth/presentation/login_or_divider.dart';
import 'package:eduquest/features/auth/presentation/login_social_buttons.dart';
import 'package:flutter/material.dart';

class LoginLayout extends StatelessWidget {
  const LoginLayout({
    super.key,
    required this.register,
    required this.options,
    required this.email,
    required this.pass,
    required this.confirm,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onToggleRegister,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  final bool register;
  final AuthOptions options;
  final TextEditingController email;
  final TextEditingController pass;
  final TextEditingController? confirm;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onToggleRegister;
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LoginHeader(register: register),
                  if (options.google || options.apple)
                    LoginSocialButtons(
                      google: options.google,
                      apple: options.apple,
                      onGoogleTap: onGoogleTap,
                      onAppleTap: onAppleTap,
                    ),
                  if (options.emailPassword) ...[
                    if (options.google || options.apple) ...[
                      const SizedBox(height: 8),
                      const LoginOrDivider(),
                      const SizedBox(height: 16),
                    ],
                    LoginEmailForm(
                      email: email,
                      pass: pass,
                      confirm: confirm,
                      obscure: obscure,
                      register: register,
                      onToggleObscure: onToggleObscure,
                      onSubmit: onSubmit,
                      onForgotPassword: onForgotPassword,
                      onToggleRegister: onToggleRegister,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
