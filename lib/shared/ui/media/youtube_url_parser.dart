String? parseYoutubeId(String url) {
  final u = Uri.tryParse(url);
  if (u == null) return null;
  final host = u.host.toLowerCase();
  if (host.contains('youtu.be')) {
    if (u.pathSegments.isEmpty) return null;
    return u.pathSegments.first;
  }
  if (host.contains('youtube.com')) {
    final v = u.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;
    final i = u.pathSegments.indexOf('embed');
    if (i >= 0 && u.pathSegments.length > i + 1) return u.pathSegments[i + 1];
    final s = u.pathSegments.indexOf('shorts');
    if (s >= 0 && u.pathSegments.length > s + 1) return u.pathSegments[s + 1];
  }
  return null;
}
