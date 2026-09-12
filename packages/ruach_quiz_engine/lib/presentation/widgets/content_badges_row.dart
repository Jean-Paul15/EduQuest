import 'package:flutter/material.dart';
import '../../domain/quiz_content_block.dart';
import '../constants.dart';

/// Ligne de badges de contenu affichant les types présents dans un quiz.
class ContentBadgesRow extends StatelessWidget {
  const ContentBadgesRow({super.key, required this.badges});
  final List<ContentTypeBadge> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Wrap(spacing: 6, runSpacing: 6,
          children: badges.map((b) => _chip(b)).toList()),
    );
  }

  Widget _chip(ContentTypeBadge b) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: gold500.withAlpha(20),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: gold500.withAlpha(60)),
    ),
    child: Text(contentTypeBadgeLabel(b),
        style: TextStyle(color: gold500, fontSize: 11,
            fontWeight: FontWeight.w500)),
  );
}
