class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.countryCode,
    required this.levelCode,
    required this.serieCode,
    this.whatsappPhone,
  });

  final String displayName;
  final String email;
  final String countryCode;
  final String levelCode;
  final String serieCode;
  final String? whatsappPhone;
}
