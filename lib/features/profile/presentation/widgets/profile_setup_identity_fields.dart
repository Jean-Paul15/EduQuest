import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileSetupIdentityFields extends StatelessWidget {
  const ProfileSetupIdentityFields({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.countryCode,
  });
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nom complet',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: RuachColors.cream900,
          ),
        ),
        const SizedBox(height: RuachSpace.s2),
        TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            hintText: 'Ex: Kossi Kodjo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RuachRadius.md),
            ),
          ),
        ),
        const SizedBox(height: RuachSpace.s3),
        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: countryCode == 'TG' ? 'Ex: 90123456' : 'Numéro',
            prefixIcon: const Icon(PhosphorIconsRegular.phone, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RuachRadius.md),
            ),
          ),
        ),
      ],
    );
  }
}
