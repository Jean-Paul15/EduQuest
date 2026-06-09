import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eduquest/features/gamification/data/gamification_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/learning/domain/learning_section.dart';
import 'package:eduquest/features/learning/presentation/pages/chapter_list_page.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'feed_item.dart';

class FeedNavigator {
  const FeedNavigator({
    required this.catalog,
    required this.gamification,
  });
  final LearningCatalogRepository catalog;
  final GamificationRepository gamification;

  Future<void> navigate(BuildContext context, FeedItem item) async {
    switch (item.kind) {
      case FeedKind.course:
        final subjectId = item.id;
        if (subjectId.isEmpty) {
          ModernSnackbar.show(
            context,
            'Ce cours est indisponible pour le moment.',
            success: false,
          );
          return;
        }
        final chapters = await catalog.chaptersBySubject(subjectId);
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChapterListPage(
              subjectId: subjectId,
              subjectLabel: item.title,
              section: LearningSection.courses,
              initialChapters: chapters,
            ),
          ),
        );
        unawaited(gamification.claimQuestByCode('open_lesson'));
      case FeedKind.contest:
        await context.push('/contest/${item.id}');
      case FeedKind.event:
        await context.push('/event/${item.id}');
      case FeedKind.unknown:
        ModernSnackbar.show(
          context,
          'Action indisponible pour ce contenu.',
          success: false,
        );
    }
  }
}
