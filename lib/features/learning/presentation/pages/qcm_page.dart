import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/learning/domain/learning_item.dart';
import 'package:eduquest/features/learning/presentation/pages/qcm_attempt_page.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class QcmPage extends StatefulWidget {
  const QcmPage({super.key});
  @override
  State<QcmPage> createState() => _QcmPageState();
}

class _QcmPageState extends State<QcmPage> {
  final _repo = LearningContentRepository();
  List<LearningItem> _items = const [];
  bool _loading = true;

  @override
  void initState() { super.initState();
    _repo.listQuizzes().then(
      (v) => mounted ? setState(() { _items = v; _loading = false; }) : null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      return const EmptyState(title: 'Aucun QCM', subtitle: 'Les QCM apparaitront ici.', icon: PhosphorIconsRegular.puzzlePiece);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
      itemBuilder: (_, i) {
        final e = _items[i];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: RuachColors.cream200),
            borderRadius: BorderRadius.circular(RuachRadius.lg)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: RuachColors.gold500.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(RuachRadius.sm)),
              child: const Icon(PhosphorIconsRegular.puzzlePiece, size: 20, color: RuachColors.gold500)),
            title: Text(e.title, style: const TextStyle(
              color: RuachColors.cream900, fontWeight: FontWeight.w500)),
            subtitle: Text('${e.count ?? 0} questions',
              style: const TextStyle(fontSize: 12, color: RuachColors.cream700)),
            trailing: const Icon(PhosphorIconsRegular.caretRight, color: RuachColors.cream700),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => QcmAttemptPage(quizId: e.id, title: e.title)))),
        );
      },
    );
  }
}
