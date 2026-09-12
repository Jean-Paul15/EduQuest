import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/data/review_repository.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_list_page.dart';
import 'package:eduquest/features/learning/presentation/widgets/learning_nav_card.dart';
import 'package:eduquest/features/learning/presentation/widgets/review_reason_pill.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Dernier onglet d'Apprendre : recommandations issues de l'analyse IA
/// (méprises + maîtrise + révisions dues), matérialisées 1×/jour — jamais de
/// contenu générique en substitution. 1 recommandation pour un profil
/// gratuit, jusqu'à 10 pour un profil payant (voir ReviewRepository).
class ReviewSectionPage extends StatefulWidget {
  const ReviewSectionPage({super.key});
  @override
  State<ReviewSectionPage> createState() => _ReviewSectionPageState();
}

class _ReviewSectionPageState extends State<ReviewSectionPage>
    with AutomaticKeepAliveClientMixin {
  final _repo = ReviewRepository();
  final _catalog = LearningCatalogRepository();
  List<ReviewRecommendation> _items = const [];
  bool _loading = true;
  String? _openingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (mounted && !forceRefresh) setState(() => _loading = true);
    final items = await _repo.recommendations(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _open(ReviewRecommendation r) async {
    setState(() => _openingId = r.chapterId);
    try {
      final chapters = await _catalog.chaptersBySubject(r.subjectId);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChapterListPage(
            subjectId: r.subjectId,
            subjectLabel: r.subjectLabel,
            section: LearningSection.courses,
            initialChapters: chapters,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return _skeleton(context);
    if (_items.isEmpty) return _empty(context);
    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, i) {
          final r = _items[i];
          return LearningNavCard(
            title: r.chapterTitle,
            subtitle: r.subjectLabel,
            icon: PhosphorIconsRegular.sparkle,
            loading: _openingId == r.chapterId,
            onTap: () => _open(r),
            footer: ReviewReasonPill(label: r.reasonLabel),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) => RefreshIndicator(
    onRefresh: () => _load(forceRefresh: true),
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * .14),
        const EmptyState(
          icon: PhosphorIconsRegular.sparkle,
          title: 'Tu es à jour !',
          subtitle:
              'Continue comme ça — reviens plus tard pour de nouvelles recommandations.',
        ),
      ],
    ),
  );

  Widget _skeleton(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(RuachSpace.s4),
    itemCount: 4,
    separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
    itemBuilder: (_, __) => RuachSkeleton(
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
      ),
    ),
  );

  @override
  bool get wantKeepAlive => true;
}
