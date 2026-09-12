/// Profil d'intérêts RIASEC (Holland) — objet-valeur immuable.
///
/// Les 6 scores sont normalisés en pourcentage **intra-individuel** :
/// `score brut de l'axe / (nombre d'items de l'axe * 4) * 100`.
/// Aucun étalonnage Sten/percentile tant que `orientation_norm_samples` est vide
/// (voir RUACHEDU_ORIENTATION_KNOWLEDGE_BASE.md, B6).
class RiasecProfile {
  const RiasecProfile({
    required this.r,
    required this.i,
    required this.a,
    required this.s,
    required this.e,
    required this.c,
  });

  final double r, i, a, s, e, c;

  static const axes = ['R', 'I', 'A', 'S', 'E', 'C'];
  static const labels = {
    'R': 'Réaliste',
    'I': 'Investigateur',
    'A': 'Artistique',
    'S': 'Social',
    'E': 'Entreprenant',
    'C': 'Conventionnel',
  };

  Map<String, double> get percents => {
    'R': r,
    'I': i,
    'A': a,
    'S': s,
    'E': e,
    'C': c,
  };

  /// Les 3 axes dominants, du plus fort au moins fort.
  List<String> get top3 {
    final ranked = percents.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return ranked.take(3).map((e) => e.key).toList(growable: false);
  }

  /// Code de Holland à 3 lettres (raccourci de lecture, pas l'info principale).
  String get hollandCode => top3.join();

  Map<String, dynamic> toJson() => percents;

  @override
  bool operator ==(Object other) =>
      other is RiasecProfile &&
      other.r == r &&
      other.i == i &&
      other.a == a &&
      other.s == s &&
      other.e == e &&
      other.c == c;

  @override
  int get hashCode => Object.hash(r, i, a, s, e, c);
}
