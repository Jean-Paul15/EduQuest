import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpace.s),
        TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            hintText: 'Ex: Kossi Kodjo',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.m),
        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: countryCode == 'TG' ? 'Ex: 90123456' : 'Numéro',
            prefixIcon: const Icon(Icons.phone_rounded, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
          ),
        ),
      ],
    );
  }
}
