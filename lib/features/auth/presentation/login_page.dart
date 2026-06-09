import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/app_config/domain/auth_options.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/auth/presentation/login_layout.dart';
import 'package:eduquest/shared/ui/widgets/ruach_snackbar.dart';
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
  AuthOptions _options = const AuthOptions(google: true, apple: true, emailPassword: true);
  bool _register = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _config.loadAuthOptions().then((v) => mounted ? setState(() => _options = v) : null);
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
      RuachSnackbar.success(context, ok);
    } catch (e) {
      if (!mounted) return;
      RuachSnackbar.error(context, userErrorMessage(e));
    }
  }

  void _onSubmit() {
    final email = _email.text.trim();
    final pass = _pass.text;
    if (_register && pass != _confirm.text) {
      RuachSnackbar.error(context, 'Les mots de passe ne correspondent pas.');
      return;
    }
    if (_register) {
      _run(() => widget.repository.signUpWithEmail(email, pass), 'Compte cree. Verifie ton email.');
      return;
    }
    _run(() => widget.repository.signInWithEmail(email, pass), 'Connexion reussie.');
  }

  void _forgotPassword() {
    final email = _email.text.trim();
    if (email.isEmpty) {
      RuachSnackbar.error(context, 'Renseigne ton email d\'abord.');
      return;
    }
    _run(() => widget.repository.resetPassword(email), 'Lien de reinitialisation envoye.');
  }

  @override
  Widget build(BuildContext context) {
    return LoginLayout(
      register: _register,
      options: _options,
      email: _email,
      pass: _pass,
      confirm: _register ? _confirm : null,
      obscure: _obscure,
      onToggleObscure: () => setState(() => _obscure = !_obscure),
      onSubmit: _onSubmit,
      onForgotPassword: _forgotPassword,
      onToggleRegister: () => setState(() => _register = !_register),
      onGoogleTap: () => _run(widget.repository.signInWithGoogle, 'Redirection Google...'),
      onAppleTap: () => _run(widget.repository.signInWithApple, 'Redirection Apple...'),
    );
  }
}
