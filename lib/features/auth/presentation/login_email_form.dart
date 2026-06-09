import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_text_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginEmailForm extends StatelessWidget {
  const LoginEmailForm({
    super.key,
    required this.email,
    required this.pass,
    required this.obscure,
    required this.register,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onToggleRegister,
    this.confirm,
  });
  final TextEditingController email;
  final TextEditingController pass;
  final TextEditingController? confirm;
  final bool obscure;
  final bool register;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onToggleRegister;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Email',
            prefixIcon: Icon(PhosphorIconsRegular.envelope, size: 20),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: pass,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: 'Mot de passe',
            prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 20),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure
                    ? PhosphorIconsRegular.eyeSlash
                    : PhosphorIconsRegular.eye,
                size: 20,
              ),
            ),
          ),
        ),
        if (!register) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: RuachTextButton(
              label: 'Mot de passe oublie ?',
              onPressed: onForgotPassword,
            ),
          ),
        ],
        if (register) ...[
          const SizedBox(height: 10),
          TextField(
            controller: confirm,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Confirmer mot de passe',
              prefixIcon: Icon(PhosphorIconsRegular.lock, size: 20),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: RuachButton(
            label: register ? 'Creer mon compte' : 'Se connecter',
            onPressed: onSubmit,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: RuachTextButton(
            label: register ? 'J\'ai deja un compte' : 'Creer un compte',
            onPressed: onToggleRegister,
          ),
        ),
      ],
    );
  }
}
