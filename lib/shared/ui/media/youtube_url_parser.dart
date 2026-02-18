String _sanitizeYoutubeInput(String raw) {
  final trimmed = raw.trim().replaceAll('"', '').replaceAll("'", '');
  if (!trimmed.contains('<iframe')) return trimmed;
  final m = RegExp(
    r'src\s*=\s*"([^"]+)"',
    caseSensitive: false,
  ).firstMatch(trimmed);
  return m?.group(1)?.trim() ?? trimmed;
}

Uri? _toUri(String raw) {
  final value = _sanitizeYoutubeInput(raw);
  final withScheme = value.startsWith('http://') || value.startsWith('https://')
      ? value
      : 'https://$value';
  return Uri.tryParse(withScheme);
}

bool isYoutubeUrl(String raw) {
  final u = _toUri(raw);
  final host = (u?.host ?? '').toLowerCase();
  if (host.contains('youtu.be') ||
      host.contains('youtube.com') ||
      host.contains('youtube-nocookie.com')) {
    return true;
  }
  return RegExp(
    r'(youtu\.be/|youtube(\-nocookie)?\.com/)',
    caseSensitive: false,
  ).hasMatch(raw);
}

String? _firstId(List<String> parts, List<String> keys) {
  for (final k in keys) {
    final i = parts.indexOf(k);
    if (i >= 0 && parts.length > i + 1) return parts[i + 1];
  }
  return null;
}

String? parseYoutubeId(String raw) {
  final u = _toUri(raw);
  if (u == null) return null;
  final host = u.host.toLowerCase();
  if (host.contains('youtu.be') && u.pathSegments.isNotEmpty) {
    return u.pathSegments.first;
  }
  if (host.contains('youtube.com') || host.contains('youtube-nocookie.com')) {
    final v = u.queryParameters['v'] ?? u.queryParameters['vi'];
    if (v != null && v.isNotEmpty) return v;
    final nested = u.queryParameters['u'];
    if (nested != null && nested.isNotEmpty) {
      final nestedId = parseYoutubeId(Uri.decodeComponent(nested));
      if (nestedId != null) return nestedId;
    }
    final fromPath = _firstId(u.pathSegments, const [
      'embed',
      'shorts',
      'live',
      'v',
    ]);
    if (fromPath != null && fromPath.isNotEmpty) return fromPath;
  }
  final m = RegExp(
    r'(?:youtu\.be/|youtube(?:\-nocookie)?\.com/(?:watch\?.*v=|embed/|v/|shorts/|live/))([A-Za-z0-9_-]{6,})',
    caseSensitive: false,
  ).firstMatch(raw);
  return m?.group(1);
}
