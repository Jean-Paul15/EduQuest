import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/features/videos/presentation/widgets/video_item_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Body for VideosPage — loading spinner, empty state, or video list.
class VideoListBody extends StatelessWidget {
  const VideoListBody({
    super.key,
    required this.loading,
    required this.refreshing,
    required this.videos,
    required this.onRefresh,
    required this.onVideoTap,
  });
  final bool loading;
  final bool refreshing;
  final List<ChapterVideo> videos;
  final Future<void> Function() onRefresh;
  final void Function(ChapterVideo) onVideoTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const VideoRowSkeletonList();
    }
    if (videos.isEmpty) {
      return RuachEmptyState(
        title: 'Aucune video',
        subtitle: 'Essaie une autre classe ou reviens plus tard.',
        icon: PhosphorIconsRegular.video,
        actionLabel: 'Recharger',
        onAction: onRefresh,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: RuachSpace.s4),
        children: [
          if (refreshing)
            const Padding(
              padding: EdgeInsets.only(bottom: RuachSpace.s2),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          ...videos.map(
            (v) => VideoItemTile(video: v, onTap: () => onVideoTap(v)),
          ),
        ],
      ),
    );
  }
}

/// Squelette de chargement de la liste vidéo — partagé entre le boot initial de VideosPage
/// et le rafraîchissement de VideoListBody, pour éviter deux formes différentes du même écran.
class VideoRowSkeletonList extends StatelessWidget {
  const VideoRowSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
      itemBuilder: (_, __) => RuachSkeleton(
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(RuachRadius.lg),
          ),
        ),
      ),
    );
  }
}
