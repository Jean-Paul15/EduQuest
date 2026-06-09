import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({
    super.key,
    required this.message,
    required this.storeUrl,
  });
  final String message;
  final String storeUrl;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(RuachSpace.s8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(RuachSpace.s4),
              decoration: BoxDecoration(
                color: s.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(RuachRadius.lg),
              ),
              child: Icon(
                PhosphorIconsRegular.arrowCircleDown,
                size: 48,
                color: s.primary,
              ),
            ),
            const SizedBox(height: RuachSpace.s6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: RuachColors.cream900,
              ),
            ),
            const SizedBox(height: RuachSpace.s6),
            RuachButton(
              label: 'Mettre a jour',
              onPressed: storeUrl.isEmpty
                  ? null
                  : () => launchUrl(
                        Uri.parse(storeUrl),
                        mode: LaunchMode.externalApplication,
                      ),
            ),
          ]),
        ),
      ),
    );
  }
}
