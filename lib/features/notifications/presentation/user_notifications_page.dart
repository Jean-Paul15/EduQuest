import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:flutter/material.dart';

class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({super.key});
  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  final _repo = UserNotificationsRepository();
  List<UserNotificationItem> _rows = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await _repo.list();
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  Future<void> _open(UserNotificationItem item) async {
    await _repo.markSeen(item.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpace.l),
        itemCount: _rows.length,
        itemBuilder: (_, i) {
          final n = _rows[i];
          return Card(
            child: ListTile(
              onTap: () => _open(n),
              title: Text(n.title),
              subtitle: Text(n.body),
              trailing: n.readAt == null
                  ? const Icon(Icons.brightness_1, size: 10, color: AppColors.accent)
                  : const Icon(Icons.done_all_rounded, size: 18),
            ),
          );
        },
      ),
    );
  }
}
