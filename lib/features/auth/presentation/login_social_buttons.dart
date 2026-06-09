import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({
    super.key,
    required this.google,
    required this.apple,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  final bool google;
  final bool apple;
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (google) ...[
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: 'Continuer avec Google',
              onPressed: onGoogleTap,
              icon: PhosphorIconsRegular.googleLogo,
            ),
          ),
          const SizedBox(height: RuachSpace.s3),
        ],
        if (apple) ...[
          SizedBox(
            width: double.infinity,
            child: RuachOutlineButton(
              label: 'Continuer avec Apple',
              onPressed: onAppleTap,
              icon: PhosphorIconsRegular.appleLogo,
            ),
          ),
          const SizedBox(height: RuachSpace.s3),
        ],
      ],
    );
  }
}
