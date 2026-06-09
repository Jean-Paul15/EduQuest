import 'package:eduquest/features/videos/domain/chapter_video.dart';
import 'package:eduquest/features/videos/presentation/widgets/video_item_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Body for VideosPage — loading spinner, empty state, or video list.
class VideoListBody extends StatelessWidget {
  const VideoListBody({
    super.key,
    required this.loading,
    required this.videos,
    required this.onRefresh,
    required this.onVideoTap,
  });
  final bool loading;
  final List<ChapterVideo> videos;
  final Future<void> Function() onRefresh;
  final void Function(ChapterVideo) onVideoTap;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (videos.isEmpty) {
      return EmptyState(
        title: 'Aucune video',
        subtitle: 'Essaie une autre classe.',
        icon: PhosphorIconsRegular.video,
        actionLabel: 'Recharger',
        onAction: onRefresh,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: RuachSpace.s4),
        children: videos.map((v) => VideoItemTile(video: v, onTap: () => onVideoTap(v))).toList(),
      ),
    );
  }
}
