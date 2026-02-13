class UpdatePolicy {
  const UpdatePolicy({
    required this.enabled,
    required this.message,
    required this.enforceExactMatch,
    required this.platform,
  });

  final bool enabled;
  final String message;
  final bool enforceExactMatch;
  final Map<String, dynamic> platform;
}

