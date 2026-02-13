String userErrorMessage(Object error) {
  final raw = error.toString().toLowerCase();
  if (raw.contains('network') || raw.contains('socket') || raw.contains('timeout')) return 'Connexion internet instable. Réessaie dans un instant.';
  if (raw.contains('auth') || raw.contains('invalid login') || raw.contains('password')) return 'Identifiants invalides ou accès non autorisé.';
  if (raw.contains('permission') || raw.contains('rls')) return 'Accès refusé pour cette opération.';
  if (raw.contains('duplicate') || raw.contains('already')) return 'Cette action a déjà été effectuée.';
  return 'Une erreur est survenue. Réessaie.';
}
