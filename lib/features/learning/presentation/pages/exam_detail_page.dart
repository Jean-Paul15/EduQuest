import 'package:eduquest/features/assistant/data/image_picker_gateway.dart';
import 'package:eduquest/features/assistant/domain/assistant_seed.dart';
import 'package:eduquest/features/assistant/presentation/assistant_seed_bus.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_command.dart';
import 'package:eduquest/shared/ui/pdf/app_pdf_viewer.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_tab_bar.dart';
import 'package:flutter/material.dart';

class ExamDetailPage extends StatelessWidget {
  const ExamDetailPage({
    super.key,
    required this.title,
    required this.paperUrl,
    required this.correctionUrl,
    this.subjectId,
    this.subjectLabel,
  });
  final String title;
  final String paperUrl;
  final String? correctionUrl;

  /// Portés par `ExamListPage` (elle les connaît déjà) uniquement pour la CTA
  /// « Corrige ma copie » — jamais requis pour afficher le sujet/la correction.
  final String? subjectId;
  final String? subjectLabel;

  @override
  Widget build(BuildContext context) {
    final hasCorr = correctionUrl != null && correctionUrl!.isNotEmpty;
    final tabs = <Tab>[
      const Tab(text: 'Sujet PDF'),
      if (hasCorr) const Tab(text: 'Correction'),
    ];
    final views = <Widget>[
      AppPdfViewer(
        url: paperUrl,
        emptyLabel: 'Le sujet de cet examen n’est pas disponible.',
      ),
      if (hasCorr)
        AppPdfViewer(
          url: correctionUrl!,
          emptyLabel: 'La correction de cet examen est indisponible.',
        ),
    ];
    return SensitiveScope(
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: RuachAppBar(
            title: title,
            showBack: true,
            bottom: RuachTabBar(tabs: tabs),
          ),
          body: TabBarView(children: views),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _correctMyCopy(context),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Corrige ma copie'),
          ),
        ),
      ),
    );
  }

  /// Photographie la copie de l'élève et l'envoie à l'assistant avec un
  /// contexte dédié (`mode: copy_review`) — jamais de lien vers le PDF,
  /// toujours une correction pas à pas dans l'app.
  ///
  /// On sait déjà, depuis cet écran, de quel sujet il s'agit (matière +
  /// année/session) : on l'indique dans le message plutôt que de laisser
  /// l'assistant le redemander — s'il manque encore l'énoncé précis, il peut
  /// appeler `find_exam_papers` avec cette même référence côté edge.
  Future<void> _correctMyCopy(BuildContext context) async {
    final attachment = await DeviceImagePickerGateway().pickFromCamera();
    if (attachment == null || !context.mounted) return;
    final reference = [subjectLabel, title].where((s) => s != null && s.isNotEmpty).join(' — ');
    AssistantSeedBus.emit(AssistantSeed(
      prompt: reference.isEmpty
          ? 'Voici ma copie manuscrite pour cet exercice. Corrige-la étape par étape.'
          : 'Voici ma copie manuscrite pour un exercice du sujet « $reference ». Corrige-la étape par étape.',
      image: attachment,
      subjectId: subjectId,
      mode: 'copy_review',
    ));
    AppDeepLinkBus.emit(const AppDeepLinkCommand(tabIndex: 1));
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
  }
}
