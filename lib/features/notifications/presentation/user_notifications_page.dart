import 'dart:async';
import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';
import 'package:eduquest/shared/analytics/app_analytics.dart';
import 'package:eduquest/shared/copy/app_copy.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_command.dart';
import 'package:eduquest/shared/deeplink/app_deep_link_parser.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/widgets/empty_state.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({
    super.key,
    this.embedded = false,
    this.repository,
    this.analytics,
  });
  final bool embedded;
  final UserNotificationsRepository? repository;
  final AppAnalytics? analytics;
  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  late final UserNotificationsRepository _repo;
  late final AppAnalytics _analytics;
  List<UserNotificationItem> _rows = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? UserNotificationsRepository();
    _analytics = widget.analytics ?? AppAnalytics();
    unawaited(
      _analytics.track('notifications_opened', category: 'notification'),
    );
    _load();
    unawaited(_load(forceRefresh: true));
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (mounted && _rows.isEmpty) setState(() => _loading = true);
    final rows = await _repo.list(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  Future<void> _open(UserNotificationItem item) async {
    unawaited(
      _analytics.track(
        'notification_opened',
        category: 'notification',
        targetType: 'notification',
        targetId: item.id,
      ),
    );
    await _repo.markSeen(item.id);
    final cmd = AppDeepLinkParser.fromRaw(item.deeplink);
    if (cmd != null) AppDeepLinkBus.emit(cmd);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = ListView.separated(
        padding: const EdgeInsets.all(RuachSpace.s4),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
        itemBuilder: (_, __) => const _NotificationSkeleton(),
      );
    } else if (_rows.isEmpty) {
      body = EmptyState(
        title: AppCopy.notificationsTitle,
        subtitle: AppCopy.notificationsSubtitle,
        icon: PhosphorIconsRegular.bell,
        actionLabel: AppCopy.retry,
        onAction: _load,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(RuachSpace.s4),
          itemCount: _rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: RuachSpace.s2),
          itemBuilder: (_, i) {
            final n = _rows[i];
            return Card(
              child: ListTile(
                onTap: () => _open(n),
                title: Text(n.title),
                subtitle: Text(n.body),
                trailing: n.readAt == null
                    ? const Icon(
                        PhosphorIconsFill.circle,
                        size: 10,
                        color: RuachColors.gold600,
                      )
                    : const Icon(PhosphorIconsRegular.checks, size: 18),
              ),
            );
          },
        ),
      );
    }
    if (widget.embedded) return body;
    return Scaffold(
      appBar: const RuachAppBar(title: 'Notifications', showBack: true),
      body: body,
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RuachSkeleton(
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
          border: Border.all(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
