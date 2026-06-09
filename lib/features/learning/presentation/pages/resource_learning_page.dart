import 'package:eduquest/app/router/app_routes.dart';
import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/learning/domain/learning_item.dart';
import 'package:eduquest/features/learning/presentation/pages/resource_list_tile.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ResourceLearningPage extends StatefulWidget {
  const ResourceLearningPage({
    super.key,
    required this.type,
    required this.emptyLabel,
  });
  final String type;
  final String emptyLabel;
  @override
  State<ResourceLearningPage> createState() => _ResourceLearningPageState();
}

class _ResourceLearningPageState extends State<ResourceLearningPage> {
  final _repo = LearningContentRepository();
  List<LearningItem> _items = const [];
  bool _loading = true;
  bool get _pdfMode =>
      widget.type == 'pdf' ||
      widget.type == 'exercise_set' ||
      widget.type == 'summary';
  bool get _videoMode => widget.type == 'video' || widget.type == 'youtube';

  @override
  void initState() {
    super.initState();
    _repo
        .listResourceType(widget.type)
        .then(
          (v) => mounted
              ? setState(() {
                  _items = v;
                  _loading = false;
                })
              : null,
        );
  }

  Future<void> _open(LearningItem item) async {
    final url = item.url;
    if (url == null || url.isEmpty) return;
    if (_pdfMode) {
      await context.pushNamed(AppRoutes.pdfViewer, queryParameters: {
        'title': item.title, 'url': url, 'emptyLabel': widget.emptyLabel,
      });
      return;
    }
    if (_videoMode) {
      final yt = isYoutubeUrl(url);
      await context.pushNamed(AppRoutes.mediaPlayer, queryParameters: {
        'title': item.title, 'url': url, 'isYoutube': yt.toString(),
      });
      return;
    }
    await context.pushNamed(AppRoutes.webView, queryParameters: {
      'title': item.title, 'url': url, 'emptyLabel': widget.emptyLabel,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      return EmptyState(
        title: 'Section vide',
        subtitle: widget.emptyLabel,
        icon: PhosphorIconsRegular.bookOpen,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(RuachSpace.s4),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
      itemBuilder: (_, i) => ResourceListTile(
        item: _items[i],
        isPdfMode: _pdfMode,
        isVideoMode: _videoMode,
        onTap: () => _open(_items[i]),
      ),
    );
  }
}
