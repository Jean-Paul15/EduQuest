import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/learning/data/learning_catalog_repository.dart';
import 'package:eduquest/features/orientation/data/orientation_repository.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/shared/supabase/supabase_bootstrap.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke: backend minimal flows when credentials are provided', (
    tester,
  ) async {
    await dotenv.load(fileName: '.env');
    await SupabaseBootstrap.initialize();
    final email = dotenv.env['ITEST_EMAIL'];
    final password = dotenv.env['ITEST_PASSWORD'];
    if (email == null || password == null) return;
    final auth = AuthRepository();
    await auth.signInWithEmail(email, password);
    final profile = await ProfileSetupRepository().load();
    expect(profile.countryCode.isNotEmpty, true);
    final subjects = await LearningCatalogRepository().subjectsForCourses();
    expect(subjects, isA<List>());
    final questionnaire = await OrientationRepository().activeQuestionnaire();
    expect(questionnaire.title.isNotEmpty, true);
    await auth.signOut();
  });
}
