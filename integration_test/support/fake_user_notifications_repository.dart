import 'package:eduquest/features/notifications/data/user_notifications_repository.dart';

class FakeUserNotificationsRepository extends UserNotificationsRepository {
  FakeUserNotificationsRepository(this.items);

  List<UserNotificationItem> items;
  String? seenId;

  @override
  Future<List<UserNotificationItem>> list({bool forceRefresh = false}) async => items;

  @override
  Future<void> markSeen(String id) async {
    seenId = id;
    items = items
        .map((item) => item.id == id
            ? UserNotificationItem(
                id: item.id,
                title: item.title,
                body: item.body,
                deeplink: item.deeplink,
                readAt: DateTime(2026),
                createdAt: item.createdAt,
              )
            : item)
        .toList(growable: false);
  }
}
