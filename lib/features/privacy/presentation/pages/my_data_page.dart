import 'dart:convert';

import 'package:eduquest/features/engagement/presentation/engagement_confirm_dialogs.dart';
import 'package:eduquest/features/privacy/data/privacy_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/user_error_message.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MyDataPage extends StatefulWidget {
  const MyDataPage({super.key});
  @override
  State<MyDataPage> createState() => _MyDataPageState();
}

class _MyDataPageState extends State<MyDataPage> {
  final _repo = PrivacyRepository();
  bool _exporting = false;
  bool _deleting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final data = await _repo.exportMyData();
      final json = const JsonEncoder.withIndent('  ').convert(data);
      await Share.shareXFiles([
        XFile.fromData(
          utf8.encode(json),
          name: 'ruachedu_mes_donnees.json',
          mimeType: 'application/json',
        ),
      ], subject: 'Mes données RuachEdu');
    } catch (e) {
      if (mounted) ModernSnackbar.show(context, userErrorMessage(e), success: false);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _requestDeletion() async {
    final confirmed = await confirmEngagementAction(
      context,
      title: 'Supprimer mon compte ?',
      message:
          'Cette action est irréversible. Ta demande sera traitée par notre équipe ; ton '
          'compte ne sera pas supprimé instantanément.',
      confirmLabel: 'Confirmer la demande',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _deleting = true);
    try {
      await _repo.requestAccountDeletion();
      if (mounted) {
        ModernSnackbar.show(
          context,
          'Demande envoyée. Elle est en attente de traitement par notre équipe.',
        );
      }
    } catch (e) {
      if (mounted) ModernSnackbar.show(context, userErrorMessage(e), success: false);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Mes données', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(RuachSpace.s4),
        children: [
          Text(
            'Conformément à notre politique de confidentialité, tu peux exporter tes données '
            'personnelles ou demander la suppression de ton compte.',
            style: TextStyle(color: s.onSurfaceVariant),
          ),
          const SizedBox(height: RuachSpace.s6),
          _Section(
            icon: PhosphorIconsRegular.downloadSimple,
            title: 'Exporter mes données',
            description:
                'Reçois une copie de tes données (profil, progression, tentatives de quiz, '
                'consentements) au format JSON.',
            child: RuachOutlineButton(
              label: 'Exporter',
              icon: PhosphorIconsRegular.export,
              loading: _exporting,
              onPressed: _export,
            ),
          ),
          const SizedBox(height: RuachSpace.s5),
          _Section(
            icon: PhosphorIconsRegular.trash,
            title: 'Supprimer mon compte',
            description:
                'Envoie une demande de suppression définitive de ton compte et de tes '
                'données. Cette demande est examinée par notre équipe avant application.',
            child: RuachButton(
              label: 'Demander la suppression',
              icon: PhosphorIconsRegular.warningCircle,
              loading: _deleting,
              onPressed: _requestDeletion,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });
  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: s.outlineVariant),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: s.primary, size: 20),
            const SizedBox(width: RuachSpace.s2),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
          ]),
          const SizedBox(height: RuachSpace.s2),
          Text(description, style: TextStyle(color: s.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: RuachSpace.s4),
          SizedBox(width: double.infinity, child: child),
        ],
      ),
    );
  }
}
