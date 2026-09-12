import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/copy/app_copy.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_input.dart';
import 'package:eduquest/shared/ui/widgets/ruach_text_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginEmailForm extends StatelessWidget {
  const LoginEmailForm({
    super.key,
    required this.email,
    required this.pass,
    required this.obscure,
    required this.obscureConfirm,
    required this.register,
    required this.loading,
    required this.onToggleObscure,
    required this.onToggleConfirmObscure,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onToggleRegister,
    this.confirm,
  });
  final TextEditingController email;
  final TextEditingController pass;
  final TextEditingController? confirm;
  final bool obscure;
  final bool obscureConfirm;
  final bool register;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleConfirmObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onToggleRegister;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RuachInput(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          hint: 'Email',
          prefixIcon: const Icon(PhosphorIconsRegular.envelope, size: 20),
        ),
        const SizedBox(height: RuachSpace.s3),
        RuachInput(
          controller: pass,
          obscure: obscure,
          hint: 'Mot de passe',
          prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 20),
          suffixIcon: IconButton(
            onPressed: onToggleObscure,
            icon: Icon(
              obscure ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
              size: 20,
            ),
          ),
        ),
        if (!register) ...[
          const SizedBox(height: RuachSpace.s1),
          Align(
            alignment: Alignment.centerRight,
            child: RuachTextButton(
              label: 'Mot de passe oublié ?',
              onPressed: onForgotPassword,
            ),
          ),
        ],
        if (register) ...[
          const SizedBox(height: RuachSpace.s3),
          RuachInput(
            controller: confirm,
            obscure: obscureConfirm,
            hint: 'Confirmer le mot de passe',
            prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 20),
            suffixIcon: IconButton(
              onPressed: onToggleConfirmObscure,
              icon: Icon(
                obscureConfirm ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
                size: 20,
              ),
            ),
          ),
        ],
        const SizedBox(height: RuachSpace.s4),
        SizedBox(
          width: double.infinity,
          child: RuachButton(
            label: register ? 'Créer mon compte' : AppCopy.signIn,
            loading: loading,
            onPressed: onSubmit,
          ),
        ),
        const SizedBox(height: RuachSpace.s2),
        Center(
          child: RuachTextButton(
            label: register ? 'J\'ai déjà un compte' : AppCopy.createAccount,
            onPressed: onToggleRegister,
          ),
        ),
      ],
    );
  }
}
