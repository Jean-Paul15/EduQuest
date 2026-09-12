/// Année académique courante au format `AAAA-AAAA+1`, déduite de la date.
///
/// L'année universitaire togolaise démarre autour de septembre : à partir du
/// mois 8 on bascule sur l'année suivante. Rien n'est figé dans le code — la
/// valeur se met à jour toute seule et le serveur applique le même défaut.
String currentAcademicYear([DateTime? now]) {
  final d = now ?? DateTime.now();
  final start = d.month >= 8 ? d.year : d.year - 1;
  return '$start-${start + 1}';
}
