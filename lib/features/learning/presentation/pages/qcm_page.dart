import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/learning/domain/learning_item.dart';
import 'package:eduquest/features/learning/presentation/pages/qcm_attempt_page.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';

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
      return const EmptyState(title: 'Aucun QCM', subtitle: 'Les QCM apparaitront ici.', icon: Icons.quiz_outlined);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpace.l),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s),
      itemBuilder: (_, i) {
        final e = _items[i];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppRadius.card)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppRadius.xs)),
              child: const Icon(Icons.quiz_rounded, size: 20, color: AppColors.primary)),
            title: Text(e.title, style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            subtitle: Text('${e.count ?? 0} questions',
              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => QcmAttemptPage(quizId: e.id, title: e.title)))),
        );
      },
    );
  }
}
