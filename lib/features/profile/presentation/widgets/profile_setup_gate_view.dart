import 'package:eduquest/features/class_selection/presentation/class_selection_panel.dart';
import 'package:eduquest/features/profile/presentation/widgets/profile_setup_identity_fields.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/loading_shimmer_page.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileSetupGateView extends StatelessWidget {
  const ProfileSetupGateView({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.countryCode,
    required this.loading,
    required this.saving,
    required this.onContinue,
    required this.onReload,
  });

  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final String countryCode;
  final bool loading;
  final bool saving;
  final VoidCallback onContinue;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    if (loading) return const LoadingShimmerPage();
    return Scaffold(
      appBar: const RuachAppBar(title: 'Completer ton profil'),
      body: ListView(
        padding: const EdgeInsets.all(RuachSpace.s4),
        children: [
          ProfileSetupIdentityFields(
            nameCtrl: nameCtrl,
            phoneCtrl: phoneCtrl,
            countryCode: countryCode,
          ),
          const SizedBox(height: RuachSpace.s4),
          ClassSelectionPanel(onChanged: onReload),
          const SizedBox(height: RuachSpace.s6),
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: saving ? 'Validation...' : 'Continuer',
              onPressed: saving ? null : onContinue,
              icon: PhosphorIconsRegular.checkCircle,
            ),
          ),
        ],
      ),
    );
  }
}
