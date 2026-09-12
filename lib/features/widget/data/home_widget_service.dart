import 'package:eduquest/shared/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Salutation selon l'heure locale (aussi recalculée côté natif à chaque tick).
String greetingForHour(int hour) {
  if (hour < 12) return 'Bonjour';
  if (hour < 18) return 'Bon après-midi';
  return 'Bonsoir';
}

/// Ingrédients poussés vers le widget écran d'accueil (rendu natif `RemoteViews`).
/// Le widget n'affiche pas tout à la fois : le provider natif choisit, selon
/// l'heure et l'urgence, la face à montrer (quête / progression / série / ticket)
/// et alterne en fondu avec la citation.
class WidgetPayload {
  const WidgetPayload({
    required this.name,
    required this.xpPct,
    required this.xpLabel,
    required this.level,
    required this.streak,
    required this.questLabel,
    required this.questValue,
    required this.ticketTier,
    required this.ticketDays,
    this.quote = '',
    this.quoteAuthor = '',
  });

  final String name; // « Awa »
  final int xpPct; // 0..100 vers le niveau suivant
  final String xpLabel; // « 60 % vers Niv. 5 »
  final int level;
  final int streak; // jours (0 = pilule masquée)
  final String questLabel; // « Défi du jour » ('' si aucune quête en attente)
  final String questValue; // « Termine 1 quiz · +20 XP »
  final String ticketTier; // « FULL » / « HALF » ('' si pas de ticket proche)
  final int ticketDays; // jours avant expiration (-1 si non pertinent)
  final String quote;
  final String quoteAuthor;
}

class HomeWidgetService {
  Future<bool> canPin() async {
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (e) {
      debugPrint('HomeWidgetService.canPin failed: $e');
      return false;
    }
  }

  Future<bool> requestPin() async {
    try {
      await HomeWidget.requestPinWidget(androidName: Env.homeWidgetAndroidName);
      return true;
    } catch (e) {
      debugPrint('HomeWidgetService.requestPin failed: $e');
      return false;
    }
  }

  Future<void> update(WidgetPayload p) async {
    try {
      await HomeWidget.saveWidgetData<String>('w_name', p.name);
      await HomeWidget.saveWidgetData<String>('w_xp_label', p.xpLabel);
      await HomeWidget.saveWidgetData<String>('w_quest_label', p.questLabel);
      await HomeWidget.saveWidgetData<String>('w_quest_value', p.questValue);
      await HomeWidget.saveWidgetData<String>('w_ticket_tier', p.ticketTier);
      await HomeWidget.saveWidgetData<String>('w_quote', p.quote);
      await HomeWidget.saveWidgetData<String>('w_quote_author', p.quoteAuthor);
      await HomeWidget.saveWidgetData<int>('w_xp', p.xpPct.clamp(0, 100));
      await HomeWidget.saveWidgetData<int>('w_level', p.level < 1 ? 1 : p.level);
      await HomeWidget.saveWidgetData<int>('w_streak', p.streak < 0 ? 0 : p.streak);
      await HomeWidget.saveWidgetData<int>('w_ticket_days', p.ticketDays);
      await HomeWidget.updateWidget(
        androidName: Env.homeWidgetAndroidName,
        iOSName: Env.homeWidgetIosName,
      );
    } catch (e) {
      debugPrint('HomeWidgetService.update failed: $e');
    }
  }
}
