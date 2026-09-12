import 'package:eduquest/features/assistant/domain/ai_chat_artifact.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/math_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Rendu d'un artifact `value` : une valeur ou une solution vérifiée.
/// Bande fine teintée, appui long pour copier — pas de carte ni de boutons.
class ArtifactValue extends StatelessWidget {
  const ArtifactValue({super.key, required this.data});
  final Map<String, dynamic> data;

  String get _latex {
    final l = '${data['latex'] ?? ''}'.trim();
    if (l.isEmpty) return '';
    return l.startsWith(r'$') ? l : '\$\$$l\$\$';
  }

  String? get _approx {
    final a = data['approx'];
    if (a is String && a.trim().isNotEmpty) return a.trim();
    final roots = data['roots'];
    if (roots is List && roots.isNotEmpty) {
      final xs = roots
          .whereType<Map>()
          .map((r) => r['approx'])
          .whereType<num>()
          .map((n) => n.toString())
          .join('  ·  ');
      if (xs.isNotEmpty) return '≈ $xs';
    }
    return null;
  }

  String get _copyText =>
      '${data['copy'] ?? data['exact'] ?? data['value'] ?? data['latex'] ?? ''}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onLongPress: _copyText.trim().isEmpty
          ? null
          : () {
              Clipboard.setData(ClipboardData(text: _copyText));
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(content: Text('Résultat copié'), duration: Duration(seconds: 1)),
              );
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: RuachSpace.s3, vertical: RuachSpace.s3,
        ),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(RuachRadius.md),
          border: Border(left: BorderSide(color: scheme.primary, width: 2.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _latex.isEmpty
                ? const Text('—')
                : MathMarkdown(data: _latex, selectable: true),
            if (_approx != null) ...[
              const SizedBox(height: 4),
              Text(
                _approx!,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Repli minimal pour les types pas encore rendus finement (steps, table…).
class ArtifactRaw extends StatelessWidget {
  const ArtifactRaw({super.key, required this.artifact});
  final AiChatArtifact artifact;

  @override
  Widget build(BuildContext context) {
    final steps = artifact.data['steps'];
    if (steps is List && steps.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in steps.whereType<Map>())
            Padding(
              padding: const EdgeInsets.only(bottom: RuachSpace.s2),
              child: MathMarkdown(data: '${s['text'] ?? ''}\n\n${s['math'] ?? ''}'),
            ),
        ],
      );
    }
    return Text(
      artifact.data.toString(),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
