import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/features/class_selection/presentation/widgets/class_selection_form.dart';
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
    required this.showName,
    required this.showPhone,
    required this.showSchooling,
    required this.levels,
    required this.levelId,
    required this.series,
    required this.seriesId,
    required this.classBusy,
    required this.onLevelChanged,
    required this.onSeriesChanged,
    required this.onContinue,
  });

  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final String countryCode;
  final bool loading;
  final bool saving;
  final bool showName;
  final bool showPhone;
  final bool showSchooling;
  final List<LevelOption> levels;
  final String? levelId;
  final List<SeriesOption> series;
  final String? seriesId;
  final bool classBusy;
  final ValueChanged<String> onLevelChanged;
  final ValueChanged<SeriesOption> onSeriesChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (loading) return const LoadingShimmerPage();
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Compléter ton profil', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(RuachSpace.s4),
        children: [
          Container(
            padding: const EdgeInsets.all(RuachSpace.s4),
            decoration: BoxDecoration(
              color: s.surface,
              borderRadius: BorderRadius.circular(RuachRadius.xl),
              border: Border.all(color: s.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'On termine juste l’essentiel.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: s.onSurface,
                  ),
                ),
                const SizedBox(height: RuachSpace.s2),
                Text(
                  'RuachEdu ne te redemandera que ce qui manque réellement.',
                  style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: RuachSpace.s4),
          ProfileSetupIdentityFields(
            nameCtrl: nameCtrl,
            phoneCtrl: phoneCtrl,
            countryCode: countryCode,
            showName: showName,
            showPhone: showPhone,
          ),
          if (showSchooling) ...[
            const SizedBox(height: RuachSpace.s4),
            Text(
              'Classe et série',
              style: TextStyle(fontWeight: FontWeight.w700, color: s.onSurface),
            ),
            const SizedBox(height: RuachSpace.s2),
            Text(
              'La sélection affichée sera enregistrée telle quelle.',
              style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: RuachSpace.s3),
            ClassSelectionForm(
              levels: levels,
              levelId: levelId,
              series: series,
              seriesId: seriesId,
              busy: classBusy,
              onLevelChanged: onLevelChanged,
              onSeriesChanged: onSeriesChanged,
              onSave: onContinue,
              showApplyButton: false,
              showSectionTitle: false,
            ),
          ],
          const SizedBox(height: RuachSpace.s6),
          SizedBox(
            width: double.infinity,
            child: RuachButton(
              label: 'Finaliser mon profil',
              loading: saving,
              onPressed: onContinue,
              icon: PhosphorIconsRegular.checkCircle,
            ),
          ),
        ],
      ),
    );
  }
}
