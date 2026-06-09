import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/engagement/domain/live_class_item.dart';
import 'package:eduquest/features/engagement/presentation/live_class_card.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return RefreshIndicator(
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, i) => LiveClassCard(
          item: _items[i],
          onJoin: () => _open(_items[i].zoomLink),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
