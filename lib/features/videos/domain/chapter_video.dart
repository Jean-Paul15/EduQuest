import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';

class ChapterVideo {
  const ChapterVideo({
    required this.id,
    required this.chapter,
    required this.title,
    required this.url,
    required this.sharedAcrossLevels,
  });

  final String id;
  final String chapter;
  final String title;
  final String url;
  final bool sharedAcrossLevels;

  String? get thumbnailUrl {
    final videoId = parseYoutubeId(url);
    return videoId == null ? null : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
}
