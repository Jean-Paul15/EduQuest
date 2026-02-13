import 'dart:convert';
import 'package:eduquest/shared/config/env.dart';
import 'package:http/http.dart' as http;

class GeminiOrientationService {
  Future<String> recommend({
    required String interests,
    required String strengths,
    required String goals,
  }) async {
    if (!Env.hasGemini) return 'Ajoute GEMINI_API_KEY dans .env.';
    final model = Env.geminiModel.isEmpty ? 'gemini-2.5-flash' : Env.geminiModel;
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${Env.geminiApiKey}',
    );
    final prompt = 'Tu es conseiller d’orientation universitaire Afrique. '
        'Interets: $interests. Forces: $strengths. Objectifs: $goals. '
        'Donne filieres recommandees + justification courte + plan 30 jours.';
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'contents': [
        {'parts': [{'text': prompt}]}
      ]
    }));
    if (response.statusCode >= 400) return 'Gemini indisponible (${response.statusCode}).';
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final c = data['candidates'] as List?;
    final t = c?.first['content']?['parts']?[0]?['text'];
    return t?.toString() ?? 'Aucune recommandation disponible.';
  }

  Future<String> recommendFromAnswers(List<Map<String, String>> answers) async {
    if (!Env.hasGemini) return 'Ajoute GEMINI_API_KEY dans .env.';
    final model = Env.geminiModel.isEmpty ? 'gemini-2.5-flash' : Env.geminiModel;
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${Env.geminiApiKey}',
    );
    final formatted = answers.map((e) => '- ${e['q']}: ${e['a']}').join('\n');
    final prompt = 'Tu es conseiller d’orientation universitaire Afrique. '
        'Analyse ces réponses (QCM + ouvertes), puis donne 3 filières adaptées, '
        'raisons, métiers possibles, plan d’action 30 jours:\n$formatted';
    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'contents': [
        {'parts': [{'text': prompt}]}
      ]
    }));
    if (response.statusCode >= 400) return 'Gemini indisponible (${response.statusCode}).';
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final c = data['candidates'] as List?;
    return c?.first['content']?['parts']?[0]?['text']?.toString() ?? 'Aucune recommandation disponible.';
  }
}
