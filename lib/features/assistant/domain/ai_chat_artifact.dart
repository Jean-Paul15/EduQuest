/// Résultat structuré produit par un outil déterministe (Edge Function
/// `compute`) et rendu comme carte interactive dans le fil de discussion.
/// Le calcul n'est jamais fait par le modèle — voir docs/26.
class AiChatArtifact {
  const AiChatArtifact({
    required this.id,
    required this.type,
    required this.title,
    required this.data,
    this.engine = 'mathjs',
    this.computeMs = 0,
  });

  final String id;

  /// `plot` | `value` | `steps` | `table` | `expression`
  final String type;
  final String title;
  final Map<String, dynamic> data;
  final String engine;
  final int computeMs;

  static AiChatArtifact? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final type = '${map['type'] ?? ''}';
    if (type.isEmpty) return null;
    final compute = map['compute'] is Map
        ? Map<String, dynamic>.from(map['compute'] as Map)
        : const <String, dynamic>{};
    return AiChatArtifact(
      id: '${map['id'] ?? ''}',
      type: type,
      title: '${map['title'] ?? ''}',
      data: map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : const <String, dynamic>{},
      engine: '${compute['engine'] ?? 'mathjs'}',
      computeMs: compute['ms'] is num ? (compute['ms'] as num).toInt() : 0,
    );
  }

  static List<AiChatArtifact> listFrom(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .map(tryParse)
        .whereType<AiChatArtifact>()
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'data': data,
    'compute': {'engine': engine, 'ms': computeMs},
  };
}
