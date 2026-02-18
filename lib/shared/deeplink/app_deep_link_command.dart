import 'package:flutter/foundation.dart';

class AppDeepLinkCommand {
  const AppDeepLinkCommand({
    this.tabIndex,
    this.message = '',
    this.success = true,
    this.kind = '',
    this.entityId = '',
  });

  final int? tabIndex;
  final String message;
  final bool success;
  final String kind;
  final String entityId;
}

class AppDeepLinkBus {
  static final ValueNotifier<AppDeepLinkCommand?> notifier =
      ValueNotifier<AppDeepLinkCommand?>(null);

  static void emit(AppDeepLinkCommand command) => notifier.value = command;
  static void clear() => notifier.value = null;
}
