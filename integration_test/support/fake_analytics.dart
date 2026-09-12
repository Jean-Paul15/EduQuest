import 'package:eduquest/shared/analytics/app_analytics.dart';

class FakeAnalytics extends AppAnalytics {
  final events = <String>[];

  @override
  Future<void> track(
    String eventName, {
    String? category,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? payload,
    bool? requiresConsent,
    int priority = 1,
    String source = 'app',
  }) async {
    events.add(eventName);
  }

  @override
  void flushNow() {}
}
