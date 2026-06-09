import 'package:flutter/material.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';

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
              icon: Icons.g_mobiledata_rounded,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (apple) ...[
          SizedBox(
            width: double.infinity,
            child: RuachOutlineButton(
              label: 'Continuer avec Apple',
              onPressed: onAppleTap,
              icon: Icons.apple,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
