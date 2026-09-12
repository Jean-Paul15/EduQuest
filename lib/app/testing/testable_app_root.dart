import 'package:eduquest/app/testing/testable_main_nav.dart';
import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/auth/presentation/login_page.dart';
import 'package:eduquest/features/class_selection/data/class_selection_repository.dart';
import 'package:eduquest/features/onboarding/presentation/onboarding_intro_page.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/features/profile/presentation/profile_setup_gate_page.dart';
import 'package:eduquest/app/theme/ruach_theme.dart';
import 'package:flutter/material.dart';

class TestableAppRoot extends StatefulWidget {
  const TestableAppRoot({
    super.key,
    required this.auth,
    required this.profileSetup,
    required this.classRepo,
    required this.pages,
    this.onboardingSeen = true,
    this.signedIn = false,
    this.profileComplete = false,
  });
  final AuthRepository auth;
  final ProfileSetupRepository profileSetup;
  final ClassSelectionRepository classRepo;
  final List<WidgetBuilder> pages;
  final bool onboardingSeen, signedIn, profileComplete;

  @override
  State<TestableAppRoot> createState() => _TestableAppRootState();
}

class _TestableAppRootState extends State<TestableAppRoot> {
  late bool _onboardingSeen, _signedIn, _profileComplete;

  @override
  void initState() {
    super.initState();
    _onboardingSeen = widget.onboardingSeen;
    _signedIn = widget.signedIn;
    _profileComplete = widget.profileComplete;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: RuachTheme.light(),
      darkTheme: RuachTheme.dark(),
      home: !_onboardingSeen
          ? OnboardingIntroPage(
              onContinue: () async => setState(() => _onboardingSeen = true),
            )
          : !_signedIn
          ? LoginPage(repository: widget.auth)
          : !_profileComplete
          ? ProfileSetupGatePage(
              onDone: () => setState(() => _profileComplete = true),
              repo: widget.profileSetup,
              classRepo: widget.classRepo,
            )
          : TestableMainNav(pages: widget.pages),
    );
  }
}
