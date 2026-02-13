import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          padding: const EdgeInsets.all(AppSpace.xxxl),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(AppSpace.l),
              decoration: BoxDecoration(
                color: s.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Icon(
                Icons.system_update_alt_rounded,
                size: 48,
                color: s.primary,
              ),
            ),
            const SizedBox(height: AppSpace.xxl),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpace.xxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => storeUrl.isEmpty
                    ? null
                    : launchUrl(
                        Uri.parse(storeUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                child: const Text('Mettre a jour'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
