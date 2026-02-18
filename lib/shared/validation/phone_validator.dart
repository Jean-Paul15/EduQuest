String normalizePhone(String input) {
  return input.replaceAll(RegExp(r'[^0-9+]'), '');
}

bool isValidPhoneForCountry({
  required String countryCode,
  required String phone,
}) {
  final raw = normalizePhone(phone);
  if (raw.isEmpty) return false;
  final cc = countryCode.trim().toUpperCase();
  if (cc == 'TG') {
    final digits = raw.replaceAll('+', '');
    return RegExp(r'^\d{8}$').hasMatch(digits);
  }
  return RegExp(r'^\+?\d{6,15}$').hasMatch(raw);
}

String? phoneValidationMessage({
  required String countryCode,
  required String phone,
}) {
  if (phone.trim().isEmpty) return 'Numéro requis.';
  if (isValidPhoneForCountry(countryCode: countryCode, phone: phone)) {
    return null;
  }
  if (countryCode.trim().toUpperCase() == 'TG') {
    return 'Numéro togolais invalide: 8 chiffres requis.';
  }
  return 'Numéro invalide.';
}
