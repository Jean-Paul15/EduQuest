import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_input.dart';
import 'package:eduquest/shared/ui/widgets/togo_phone_input.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileSetupIdentityFields extends StatelessWidget {
  const ProfileSetupIdentityFields({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.countryCode,
    this.showName = true,
    this.showPhone = true,
  });
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final String countryCode;
  final bool showName;
  final bool showPhone;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName) ...[
          Text(
            'Nom complet',
            style: TextStyle(fontWeight: FontWeight.w600, color: s.onSurface),
          ),
          const SizedBox(height: RuachSpace.s2),
          RuachInput(
            controller: nameCtrl,
            hint: 'Ex: Kossi Kodjo',
            prefixIcon: const Icon(PhosphorIconsRegular.user, size: 18),
          ),
        ],
        if (showName && showPhone) const SizedBox(height: RuachSpace.s3),
        if (showPhone)
          countryCode == 'TG'
              ? TogoPhoneInput(controller: phoneCtrl, label: 'Téléphone')
              : RuachInput(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  hint: 'Numéro',
                  label: 'Téléphone',
                  prefixIcon: const Icon(PhosphorIconsRegular.phone, size: 18),
                ),
      ],
    );
  }
}
