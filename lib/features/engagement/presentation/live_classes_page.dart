import 'package:eduquest/features/engagement/data/live_classes_repository.dart';
import 'package:eduquest/features/engagement/domain/live_class_item.dart';
import 'package:eduquest/features/learning/data/learning_scope_repository.dart';
import 'package:eduquest/features/engagement/presentation/live_class_card.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eduquest/shared/realtime/realtime_refreshable.dart';

class LiveClassesPage extends StatefulWidget {
  const LiveClassesPage({super.key, this.embedded = false});
  final bool embedded;
  @override
  State<LiveClassesPage> createState() => _LiveClassesPageState();
}

class _LiveClassesPageState extends State<LiveClassesPage>
    with AutomaticKeepAliveClientMixin, RealtimeRefreshable<LiveClassesPage> {
  @override
  List<String> get realtimeNamespaces => const ['hub:lives'];

  @override
  Future<void> reloadFromRealtime() => _load(forceRefresh: true);

  final _repo = LiveClassesRepository();
  List<LiveClassItem> _items = const [];
  bool _loading = true;
  bool _seriesBlocked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final scope = await LearningScopeRepository().current();
    if (mounted && _items.isEmpty) {
      setState(() => _loading = true);
    }
    final data = await _repo.list(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() {
        _items = data;
        _loading = false;
        _seriesBlocked = (scope?.seriesId?.isEmpty ?? true) || scope?.seriesId == null;
      });
    }
  }

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget body;
    if (_loading) {
      body = ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, __) => const _LiveClassSkeleton(),
      );
    } else if (_items.isEmpty) {
      body = RuachEmptyState(
        icon: PhosphorIconsRegular.videoCamera,
        title: _seriesBlocked ? 'Série requise' : 'Aucun live planifié',
        subtitle: _seriesBlocked
            ? 'Les lives apparaîtront ici dès qu’une série active sera liée à ta classe.'
            : 'Les cours Zoom à venir apparaîtront ici.',
        actionLabel: 'Actualiser',
        onAction: () => _load(forceRefresh: true),
      );
    } else {
      body = RefreshIndicator(
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
    if (widget.embedded) return body;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Cours en direct', showBack: true),
      body: body,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _LiveClassSkeleton extends StatelessWidget {
  const _LiveClassSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RuachSkeleton(
      child: Container(
        height: 126,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          border: Border.all(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
