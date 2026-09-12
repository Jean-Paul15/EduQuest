/// Durees de fraicheur encore utilisees. Le contenu (cours, epreuves, hub) n'a
/// plus de TTL : il est invalide de facon ciblee par le temps reel (Broadcast).
class CachePolicy {
  static const hubBadge = Duration(seconds: 45);
  static const appConfig = Duration(minutes: 20);
}
