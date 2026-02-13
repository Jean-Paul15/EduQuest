import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/engagement/domain/live_class_item.dart';
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
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted && _items.isEmpty) setState(() => _loading = true);
    final data = await _repo.list();
    if (mounted) setState(() { _items = data; _loading = false; });
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      return const EmptyState(
        title: 'Aucun live planifie',
        subtitle: 'Les cours Zoom a venir apparaitront ici.',
      );
    }
    final s = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpace.l),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.s),
        itemBuilder: (_, i) => _card(_items[i], s),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _card(LiveClassItem e, ColorScheme s) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.m),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.s),
          decoration: BoxDecoration(
            color: s.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(Icons.videocam_rounded, size: 20, color: s.primary),
        ),
        const SizedBox(width: AppSpace.m),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(
              '${e.startsAt.toLocal()} — ${e.endsAt.toLocal()}',
              style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        )),
        const SizedBox(width: AppSpace.s),
        FilledButton(
          onPressed: () => _open(e.zoomLink),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
            textStyle: const TextStyle(fontSize: 13),
          ),
          child: const Text('Rejoindre'),
        ),
      ]),
    );
  }
}
