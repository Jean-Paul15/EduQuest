import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileLoadErrorView extends StatelessWidget {
  const ProfileLoadErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(RuachSpace.s6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.cloudSlash,
                    size: 42,
                    color: colors.primary,
                  ),
                  const SizedBox(height: RuachSpace.s4),
                  Text(
                    'Profil momentanément indisponible',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: RuachSpace.s2),
                  Text(
                    'Nous n’avons pas pu vérifier ton profil. Tes informations ne sont pas perdues.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: RuachSpace.s5),
                  SizedBox(
                    width: double.infinity,
                    child: RuachButton(label: 'Réessayer', onPressed: onRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
