import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/app_config/domain/auth_options.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/user_error_message.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.repository});
  final AuthRepository repository;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _config = AppConfigRepository();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  AuthOptions _options = const AuthOptions(
    google: true,
    apple: true,
    emailPassword: true,
  );
  bool _register = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _config.loadAuthOptions().then(
      (v) => mounted ? setState(() => _options = v) : null,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String ok) async {
    try {
      await action();
      if (!mounted) return;
      ModernSnackbar.show(context, ok);
    } catch (e) {
      if (!mounted) return;
      ModernSnackbar.show(context, userErrorMessage(e), success: false);
    }
  }

  void _onSubmit() {
    final email = _email.text.trim();
    final pass = _pass.text;
    if (_register && pass != _confirm.text) {
      ModernSnackbar.show(
        context,
        'Les mots de passe ne correspondent pas.',
        success: false,
      );
      return;
    }
    if (_register) {
      _run(
        () => widget.repository.signUpWithEmail(email, pass),
        'Compte cree. Verifie ton email.',
      );
      return;
    }
    _run(
      () => widget.repository.signInWithEmail(email, pass),
      'Connexion reussie.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: s.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: s.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _register ? 'Creer un compte' : 'Bon retour',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Acces securise EduQuest',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_options.google) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _run(
                          widget.repository.signInWithGoogle,
                          'Redirection Google...',
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded),
                        label: const Text('Continuer avec Google'),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_options.apple) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _run(
                          widget.repository.signInWithApple,
                          'Redirection Apple...',
                        ),
                        icon: const Icon(Icons.apple),
                        label: const Text('Continuer avec Apple'),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_options.emailPassword) ...[
                    if (_options.google || _options.apple) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ou',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pass,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Mot de passe',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    if (!_register) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            final email = _email.text.trim();
                            if (email.isEmpty) {
                              ModernSnackbar.show(
                                context,
                                'Renseigne ton email d\'abord.',
                                success: false,
                              );
                              return;
                            }
                            _run(
                              () => widget.repository.resetPassword(email),
                              'Lien de reinitialisation envoye.',
                            );
                          },
                          child: const Text('Mot de passe oublie ?'),
                        ),
                      ),
                    ],
                    if (_register) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _confirm,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Confirmer mot de passe',
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _onSubmit,
                        child: Text(
                          _register ? 'Creer mon compte' : 'Se connecter',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _register = !_register),
                        child: Text(
                          _register
                              ? 'J\'ai deja un compte'
                              : 'Creer un compte',
                        ),
                      ),
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
