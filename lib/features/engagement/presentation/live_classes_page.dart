import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/engagement/domain/live_class_item.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LiveClassesPage extends StatefulWidget {
  const LiveClassesPage({super.key});
  @override
  State<LiveClassesPage> createState() => _LiveClassesPageState();
}

class _LiveClassesPageState extends State<LiveClassesPage>
    with AutomaticKeepAliveClientMixin {
  final _repo = LiveClassesRepository();
  List<LiveClassItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load(forceRefresh: true);
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (mounted && _items.isEmpty) {
      setState(() => _loading = true);
    }
    final data = await _repo.list(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() {
        _items = data;
        _loading = false;
      });
    }
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const EmptyState(
        title: 'Aucun live planifie',
        subtitle: 'Les cours Zoom a venir apparaitront ici.',
      );
    }
    final s = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, i) => _card(_items[i], s),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _card(LiveClassItem e, ColorScheme s) {
    return Container(
      padding: const EdgeInsets.all(RuachSpace.s3),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: RuachColors.cream200),
        borderRadius: BorderRadius.circular(RuachRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(RuachSpace.s2),
            decoration: BoxDecoration(
              color: s.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(RuachRadius.sm),
            ),
            child: Icon(PhosphorIconsRegular.videoCamera, size: 20, color: s.primary),
          ),
          const SizedBox(width: RuachSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: RuachColors.cream900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${e.startsAt.toLocal()} — ${e.endsAt.toLocal()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: RuachColors.cream700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RuachSpace.s2),
          RuachButton(
            label: 'Rejoindre',
            onPressed: () => _open(e.zoomLink),
          ),
        ],
      ),
    );
  }
}
