import 'package:eduquest/features/assistant/domain/ai_chat_artifact.dart';
import 'package:eduquest/features/assistant/presentation/widgets/assistant_artifact_plot.dart';
import 'package:eduquest/features/assistant/presentation/widgets/assistant_artifact_value.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const _plotPreviewHeight = 176.0;

IconData _glyph(String type) => switch (type) {
  'plot' => PhosphorIconsRegular.chartLine,
  'value' => PhosphorIconsRegular.equals,
  'steps' => PhosphorIconsRegular.listNumbers,
  'table' => PhosphorIconsRegular.table,
  _ => PhosphorIconsRegular.function,
};

String _label(String type) => switch (type) {
  'plot' => 'Courbe',
  'value' => 'Résultat',
  'steps' => 'Solution',
  'table' => 'Tableau',
  _ => 'Résultat',
};

/// Résultat calculé rendu pleine largeur, sous le texte de l'assistant (jamais
/// imbriqué dans la bulle). Chrome minimal : un intitulé + le corps.
class AssistantArtifact extends StatelessWidget {
  const AssistantArtifact({super.key, required this.artifact});
  final AiChatArtifact artifact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = artifact.title.isEmpty ? _label(artifact.type) : artifact.title;

    final body = switch (artifact.type) {
      'plot' => _PlotPreview(artifact: artifact),
      'value' => ArtifactValue(data: artifact.data),
      _ => ArtifactRaw(artifact: artifact),
    };

    return _Appear(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: RuachSpace.s1, left: 2, right: 2),
            child: Row(
              children: [
                Icon(_glyph(artifact.type), size: 13, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 6),
                _CalcBadge(),
              ],
            ),
          ),
          body,
        ],
      ),
    );
  }
}

class _CalcBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5, height: 5,
          decoration: const BoxDecoration(
            color: RuachColors.success600, shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'calculé',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PlotPreview extends StatelessWidget {
  const _PlotPreview({required this.artifact});
  final AiChatArtifact artifact;

  Future<void> _openFullscreen(BuildContext context) async {
    // On retire le focus avant de naviguer, et de nouveau au retour : sinon le
    // champ de saisie récupère le focus au pop de la route et le clavier
    // remonte tout seul.
    FocusManager.instance.primaryFocus?.unfocus();
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ArtifactPlotPage(artifact: artifact),
    ));
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RuachRadius.md),
        child: Container(
          height: _plotPreviewHeight,
          color: scheme.surface,
          child: Stack(
            children: [
              Positioned.fill(
                child: ArtifactPlot(data: artifact.data),
              ),
              Positioned(
                right: 8, top: 8,
                child: Icon(Icons.open_in_full_rounded,
                    size: 15, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Squelette pleine largeur affiché pendant qu'un outil tourne — même hauteur
/// que l'aperçu final, donc aucun saut de layout à l'arrivée du résultat.
class AssistantArtifactSkeleton extends StatelessWidget {
  const AssistantArtifactSkeleton({super.key, this.type = 'plot', this.label});
  final String type;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: RuachSpace.s1, left: 2),
          child: Row(children: [
            Icon(_glyph(type), size: 13, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label ?? 'Calcul en cours…',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ]),
        ),
        RuachSkeleton(
          child: Container(
            height: type == 'plot' ? _plotPreviewHeight : 44,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(RuachRadius.md),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fondu + légère montée à la première apparition ; inerte si l'utilisateur a
/// demandé de réduire les animations.
class _Appear extends StatefulWidget {
  const _Appear({required this.child});
  final Widget child;
  @override
  State<_Appear> createState() => _AppearState();
}

class _AppearState extends State<_Appear> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, .04),
      duration: RuachMotion.appear,
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: RuachMotion.appear,
        child: widget.child,
      ),
    );
  }
}
