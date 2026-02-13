class AuthOptions {
  const AuthOptions({
    required this.google,
    required this.apple,
    required this.emailPassword,
  });

  final bool google;
  final bool apple;
  final bool emailPassword;
}

