import 'package:flutter/foundation.dart';

class AppDeepLinkCommand {
  const AppDeepLinkCommand({
    this.tabIndex,
    this.message = '',
    this.success = true,
    this.kind = '',
    this.entityId = '',
    this.params = const {},
  });

  final int? tabIndex;
  final String message;
  final bool success;
  final String kind;
  final String entityId;

  /// Paramètres bruts du lien (tous les query params), pour les `kind` qui
  /// ont besoin de plus que `tab`/`kind`/`id` — ex. `assistant_seed` lit
  /// `subject`/`label` pour préremplir l'assistant avec le bon contexte.
  final Map<String, String> params;
}

class AppDeepLinkBus {
  static final ValueNotifier<AppDeepLinkCommand?> notifier =
      ValueNotifier<AppDeepLinkCommand?>(null);

  static void emit(AppDeepLinkCommand command) => notifier.value = command;
  static void clear() => notifier.value = null;
}
