import 'package:eduquest/features/assistant/domain/assistant_seed.dart';
import 'package:flutter/foundation.dart';

/// Bus d'un seul message vers l'onglet Assistant, calqué sur `AppDeepLinkBus` :
/// retient la dernière valeur tant qu'elle n'a pas été consommée, pour couvrir
/// le cas où l'onglet n'a encore jamais été monté (`LazyTabStack`).
class AssistantSeedBus {
  static final ValueNotifier<AssistantSeed?> notifier =
      ValueNotifier<AssistantSeed?>(null);

  static void emit(AssistantSeed seed) => notifier.value = seed;
  static void clear() => notifier.value = null;
}
