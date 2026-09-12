import 'package:eduquest/features/assistant/presentation/ai_assistant_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_ai_assistant_repository.dart';
import 'support/fake_analytics.dart';
import 'support/fake_image_picker_gateway.dart';
import 'support/fake_offline_view_state.dart';
import 'support/test_harness.dart';

void main() {
  testWidgets('assistant:ask-and-answer shows no source citation', (tester) async {
    await pumpTestApp(
      tester,
      AiAssistantPage(
        repository: FakeAiAssistantRepository(),
        analytics: FakeAnalytics(),
        offlineState: FakeOfflineViewState(),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Explique-moi la leçon');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('Réponse de test'), findsOneWidget);
    expect(find.textContaining('Sources'), findsNothing);
  });

  testWidgets('assistant:error-state shows actionable fallback', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      AiAssistantPage(
        repository: FakeAiAssistantRepository(throwOnAsk: true),
        analytics: FakeAnalytics(),
        offlineState: FakeOfflineViewState(),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Question');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('pas assez d’informations'), findsOneWidget);
  });

  testWidgets('assistant:attach-image-shows-chip-and-clear', (tester) async {
    await pumpTestApp(
      tester,
      AiAssistantPage(
        repository: FakeAiAssistantRepository(),
        analytics: FakeAnalytics(),
        offlineState: FakeOfflineViewState(),
        imagePicker: FakeImagePickerGateway(),
      ),
    );
    await tester.tap(find.byIcon(Icons.image_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choisir dans la galerie'));
    await tester.pumpAndSettle();
    expect(find.text('Image jointe'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Image jointe'), findsNothing);
  });

  testWidgets('assistant:status-cycle-visible-during-send', (tester) async {
    await pumpTestApp(
      tester,
      AiAssistantPage(
        repository: FakeAiAssistantRepository(delay: const Duration(seconds: 2)),
        analytics: FakeAnalytics(),
        offlineState: FakeOfflineViewState(),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Question longue');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Je cherche dans tes cours'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('assistant:streams-tokens-progressively-then-finalizes', (tester) async {
    await pumpTestApp(
      tester,
      AiAssistantPage(
        repository: FakeAiAssistantRepository(
          delay: const Duration(milliseconds: 200),
          streamChunks: const ['Bon', 'jour ', 'à ', 'toi.'],
        ),
        analytics: FakeAnalytics(),
        offlineState: FakeOfflineViewState(),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Salut');
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    // Après le 1er fragment (~200ms) : le libellé de statut a disparu, remplacé par le texte
    // partiel — pas de bulle vide entre les deux états.
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.textContaining('Je cherche dans tes cours'), findsNothing);
    expect(find.textContaining('Bon'), findsOneWidget);
    // Après le 2e fragment : le texte a grandi, toujours dans la même bulle de streaming.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('Bonjour à'), findsOneWidget);
    // Une fois le flux terminé : le message final remplace la bulle de streaming (pas de doublon).
    await tester.pumpAndSettle();
    expect(find.textContaining('Bonjour à toi.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
