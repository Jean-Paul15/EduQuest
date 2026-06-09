import 'package:eduquest/features/learning/presentation/pages/chapter_resource_list_page.dart';
import 'package:eduquest/features/learning/domain/chapter_resource.dart';
import 'package:eduquest/shared/security/sensitive_scope.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:flutter/material.dart';

class ChapterMediaPage extends StatelessWidget {
  const ChapterMediaPage({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    required this.type,
    this.initialItems,
  });
  final String chapterId;
  final String chapterTitle;
  final String type;
  final List<ChapterResource>? initialItems;

  @override
  Widget build(BuildContext context) {
    final isYoutube = type == 'youtube';
    return SensitiveScope(
      child: Scaffold(
        appBar: RuachAppBar(title: chapterTitle),
        body: ChapterResourceListPage(
          chapterId: chapterId,
          type: type,
          emptyLabel: isYoutube
              ? 'Aucune vidéo YouTube pour ce chapitre.'
              : 'Aucune vidéo pour ce chapitre.',
          initialItems: initialItems,
        ),
      ),
    );
  }
}
