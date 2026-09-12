import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/app_config/domain/auth_options.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/auth/presentation/login_layout.dart';
import 'package:eduquest/features/auth/presentation/register_steps_page.dart';
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
  AuthOptions _options = const AuthOptions(google: true, apple: true, emailPassword: true);
  bool _obscure = true, _loading = false;

  @override
  void initState() {
    super.initState();
    _config.loadAuthOptions().then((v) => mounted ? setState(() => _options = v) : null);
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String ok) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await action();
      if (!mounted) return;
      RuachSnackbar.success(context, ok);
    } catch (e) {
      if (!mounted) return;
      RuachSnackbar.error(context, userErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSubmit() {
    final email = _email.text.trim();
    final pass = _pass.text;
    if (email.isEmpty || !email.contains('@')) {
      RuachSnackbar.error(context, 'Entre une adresse email valide.');
      return;
    }
    if (pass.isEmpty) {
      RuachSnackbar.error(context, 'Entre ton mot de passe.');
      return;
    }
    _run(
      () => widget.repository.signInWithEmail(email, pass),
      'Connexion réussie.',
    );
  }

  void _forgotPassword() {
    final email = _email.text.trim();
    if (email.isEmpty) {
      RuachSnackbar.error(context, 'Renseigne ton email d\'abord.');
      return;
    }
    _run(
      () => widget.repository.resetPassword(email),
      'Lien de réinitialisation envoyé.',
    );
  }

  void _goRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterStepsPage(repository: widget.repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoginLayout(
      register: false,
      options: _options,
      email: _email,
      pass: _pass,
      confirm: null,
      obscure: _obscure,
      obscureConfirm: false,
      loading: _loading,
      onToggleObscure: () => setState(() => _obscure = !_obscure),
      onToggleConfirmObscure: () {},
      onSubmit: _onSubmit,
      onForgotPassword: _forgotPassword,
      onToggleRegister: _goRegister,
      onGoogleTap: () =>
          _run(widget.repository.signInWithGoogle, 'Redirection Google...'),
      onAppleTap: () =>
          _run(widget.repository.signInWithApple, 'Redirection Apple...'),
    );
  }
}
