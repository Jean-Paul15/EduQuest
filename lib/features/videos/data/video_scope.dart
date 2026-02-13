class VideoScope {
  static bool isVisible({
    required Map<String, dynamic> scope,
    required String levelCode,
    required String serieCode,
  }) {
    if (scope.isEmpty) return true;
    final levels = (scope['levels'] as List?)?.map((e) => '$e').toSet() ?? {};
    final series = (scope['series'] as List?)?.map((e) => '$e').toSet() ?? {};
    final levelOk = levels.isEmpty || levels.contains(levelCode);
    final serieOk = series.isEmpty || series.contains(serieCode);
    return levelOk && serieOk;
  }

  static bool isShared(Map<String, dynamic> scope) {
    final levels = (scope['levels'] as List?) ?? const [];
    return levels.length > 1 || levels.isEmpty;
  }
}

