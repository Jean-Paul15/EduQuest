import 'package:eduquest/features/orientation/data/orientation_bilan_pdf.dart';
import 'package:eduquest/features/orientation/domain/orientation_recommendation.dart';
import 'package:eduquest/features/orientation/domain/recommended_field.dart';
import 'package:eduquest/features/orientation/presentation/result/field_card.dart';
import 'package:eduquest/features/orientation/presentation/result/riasec_radar.dart';
import 'package:eduquest/features/orientation/presentation/widgets/labeled_bullet.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/widgets/compact_markdown.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

const _tierTitles = {
  RecommendationTier.securite: 'Des choix sûrs',
  RecommendationTier.ambitieux: 'Des choix ambitieux',
  RecommendationTier.alternative: 'Des alternatives courtes',
};

/// Écran de résultats en révélation séquentielle : chaque section apparaît
/// (fondu + translation) quand elle entre dans la zone visible.
class OrientationResultView extends StatelessWidget {
  const OrientationResultView({
    super.key,
    required this.reco,
    required this.onRestart,
  });
  final OrientationRecommendation reco;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final sections = <Widget>[
      _Header(reco: reco),
      RiasecRadar(profile: reco.profile),
      if ((reco.aiSummary ?? '').isNotEmpty)
        _Card(child: CompactMarkdown(data: reco.aiSummary!)),
      for (final tier in RecommendationTier.values)
        if (reco.tier(tier).isNotEmpty) _TierBlock(tier: tier, reco: reco),
      if (reco.strengths.isNotEmpty)
        _Section(title: 'Tes points forts', items: reco.strengths),
      if (reco.nextSteps.isNotEmpty)
        _Section(
          title: 'Prochaines étapes',
          items: reco.nextSteps,
          icon: Icons.check_circle_outline,
        ),
      _Actions(reco: reco, onRestart: onRestart),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: sections.length,
      itemBuilder: (context, i) => _Reveal(
        key: ValueKey(i),
        delayMs: reduce ? 0 : (i * 60).clamp(0, 400),
        child: Padding(
          padding: const EdgeInsets.only(bottom: RuachSpace.s3),
          child: sections[i],
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({super.key, required this.child, required this.delayMs});
  final Widget child;
  final int delayMs;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + delayMs),
      curve: Curves.easeOut,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.reco});
  final OrientationRecommendation reco;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            reco.profile.hollandCode,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: RuachSpace.s2),
        if (!reco.normsReady)
          Text(
            'Normes locales en cours de validation.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: RuachSpace.s2),
        Text(
          reco.uncertaintyNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TierBlock extends StatelessWidget {
  const _TierBlock({required this.tier, required this.reco});
  final RecommendationTier tier;
  final OrientationRecommendation reco;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            _tierTitles[tier] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: RuachSpace.s2),
        ...reco.tier(tier).map((f) => FieldCard(field: f)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items, this.icon});
  final String title;
  final List<String> items;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: RuachSpace.s2),
        ...items.map((t) => LabeledBullet(text: t, icon: icon)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(RuachRadius.xl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _Actions extends StatefulWidget {
  const _Actions({required this.reco, required this.onRestart});
  final OrientationRecommendation reco;
  final VoidCallback onRestart;
  @override
  State<_Actions> createState() => _ActionsState();
}

class _ActionsState extends State<_Actions> {
  bool _busy = false;

  Future<void> _shareBilan() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await buildOrientationBilanPdf(widget.reco);
      await Printing.sharePdf(
        bytes: bytes,
        filename: orientationBilanFilename(widget.reco),
      );
    } catch (_) {
      // Repli : si la génération ou le partage du PDF échoue, on partage le
      // texte de synthèse plutôt que de bloquer l'utilisateur.
      final summary = widget.reco.aiSummary;
      if (summary != null && summary.isNotEmpty) {
        await Share.share(summary);
      } else if (mounted) {
        ModernSnackbar.show(context, 'Partage indisponible pour le moment.',
            success: false);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RuachButton(
          label: 'Partager mon bilan',
          loading: _busy,
          onPressed: _shareBilan,
        ),
        const SizedBox(height: RuachSpace.s2),
        RuachOutlineButton(
          label: 'Refaire le test dans 6 mois',
          onPressed: widget.onRestart,
        ),
      ],
    );
  }
}
