import 'package:eduquest/features/learning/data/learning_content_repository.dart';
import 'package:eduquest/features/learning/domain/learning_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/media/app_media_player_page.dart';
import 'package:eduquest/shared/ui/media/youtube_url_parser.dart';
import 'package:eduquest/shared/ui/pdf/app_pdf_viewer.dart';
import 'package:eduquest/shared/ui/web/app_webview_page.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
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
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AppPdfViewerPage(
            title: item.title,
            url: url,
            emptyLabel: widget.emptyLabel,
          ),
        ),
      );
      return;
    }
    if (_videoMode) {
      final yt = isYoutubeUrl(url);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AppMediaPlayerPage(title: item.title, url: url, isYoutube: yt),
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppWebViewPage(
          title: item.title,
          url: url,
          emptyLabel: widget.emptyLabel,
        ),
      ),
    );
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
      itemBuilder: (_, i) {
        final e = _items[i];
        final icon = _pdfMode
            ? PhosphorIconsRegular.filePdf
            : _videoMode
            ? PhosphorIconsRegular.playCircle
            : PhosphorIconsRegular.browser;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: RuachColors.cream200),
            borderRadius: BorderRadius.circular(RuachRadius.lg),
          ),
          child: ListTile(
            title: Text(
              e.title,
              style: const TextStyle(
                color: RuachColors.cream900,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              e.subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: RuachColors.cream700,
              ),
            ),
            trailing: Icon(icon, color: RuachColors.gold500),
            onTap: () => _open(e),
          ),
        );
      },
    );
  }
}
