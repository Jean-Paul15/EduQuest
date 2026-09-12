import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/auth/presentation/auth_back_guard.dart';
import 'package:eduquest/features/auth/presentation/signup_bridge_page.dart';
import 'package:eduquest/features/auth/presentation/signup_consent_card.dart';
import 'package:eduquest/features/class_selection/data/class_selection_repository.dart';
import 'package:eduquest/features/class_selection/domain/level_option.dart';
import 'package:eduquest/features/class_selection/domain/series_option.dart';
import 'package:eduquest/features/class_selection/presentation/widgets/class_selection_form.dart';
import 'package:eduquest/features/learning/domain/learning_subject.dart';
import 'package:eduquest/features/legal/presentation/legal_document_page.dart';
import 'package:eduquest/features/profile/data/profile_setup_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/ui/design_tokens.dart';
import 'package:eduquest/shared/ui/modern_snackbar.dart';
import 'package:eduquest/shared/ui/user_error_message.dart';
import 'package:eduquest/shared/ui/widgets/ruach_button.dart';
import 'package:eduquest/shared/ui/widgets/ruach_app_bar.dart';
import 'package:eduquest/shared/ui/widgets/ruach_input.dart';
import 'package:eduquest/shared/ui/widgets/ruach_progress.dart';
import 'package:eduquest/shared/ui/widgets/ruach_outline_button.dart';
import 'package:eduquest/shared/ui/widgets/togo_phone_input.dart';
import 'package:eduquest/shared/validation/phone_validator.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterStepsPage extends StatefulWidget {
  const RegisterStepsPage({
    super.key,
    required this.repository,
    this.classRepo,
    this.profileSetup,
  });
  final AuthRepository repository;
  final ClassSelectionRepository? classRepo;
  final ProfileSetupRepository? profileSetup;

  @override
  State<RegisterStepsPage> createState() => _RegisterStepsPageState();
}

class _RegisterStepsPageState extends State<RegisterStepsPage> {
  late final ClassSelectionRepository _classRepo;
  late final ProfileSetupRepository _profileSetup;
  final _nameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  List<LevelOption> _levels = const [];
  List<SeriesOption> _series = const [];
  List<LearningSubject> _studySubjects = const [];
  String? _levelId, _seriesId;
  String? _primaryGoal, _targetExam, _studyRhythm;
  Set<String> _strongSubjectIds = <String>{};
  Set<String> _weakSubjectIds = <String>{};
  Set<String> _interestSubjectIds = <String>{};
  bool _busyClass = false;
  bool _busyStudy = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _legalAccepted = false;
  bool _aiEnabled = false;
  int _step = 0;
  bool _loading = false;
  String? _classError;
  List<String> _schoolSuggestions = const [];
  bool _loadingSchools = false;

  @override
  void initState() {
    super.initState();
    _classRepo = widget.classRepo ?? ClassSelectionRepository();
    _profileSetup = widget.profileSetup ?? ProfileSetupRepository();
    _loadClassData();
    _schoolCtrl.addListener(_onSchoolTextChanged);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onSchoolTextChanged() {
    final q = _schoolCtrl.text.trim();
    if (q.isEmpty) {
      if (mounted) setState(() => _schoolSuggestions = const []);
      return;
    }
    _fetchSchoolSuggestions(q);
  }

  Future<void> _fetchSchoolSuggestions(String query) async {
    if (_loadingSchools) return;
    setState(() => _loadingSchools = true);
    try {
      if (!Env.hasSupabase) {
        if (mounted) {
          setState(() {
            _loadingSchools = false;
            _schoolSuggestions = [query];
          });
        }
        return;
      }
      final r = await Supabase.instance.client
          .from('partner_schools')
          .select('name')
          .ilike('name', '%$query%')
          .limit(8);
      final names = (r as List).map((e) => e['name'].toString()).toList();
      // Always include the user's typed text as a creatable option
      if (!names.any((n) => n.toLowerCase() == query.toLowerCase())) {
        names.insert(0, query);
      }
      if (mounted) {
        setState(() {
          _schoolSuggestions = names;
          _loadingSchools = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _schoolSuggestions = [query];
          _loadingSchools = false;
        });
      }
    }
  }

  Future<void> _loadClassData() async {
    try {
      final levels = await _classRepo.activeLevels();
      final levelId = levels.isEmpty ? null : levels.first.id;
      final series = levelId == null
          ? const <SeriesOption>[]
          : await _classRepo.activeSeries(levelId);
      if (!mounted) return;
      setState(() {
        _levels = levels;
        _levelId = levelId;
        _series = series;
        _seriesId = series.isEmpty ? null : series.first.id;
        _classError = null;
      });
      await _loadStudySubjects();
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _classError =
            'Impossible de charger les classes. Vérifie ta connexion.',
      );
    }
  }

  Future<void> _onLevelChanged(String v) async {
    setState(() => _busyClass = true);
    final s = await _classRepo.activeSeries(v);
    if (!mounted) return;
    setState(() {
      _levelId = v;
      _series = s;
      _seriesId = s.isEmpty ? null : s.first.id;
      _busyClass = false;
    });
    await _loadStudySubjects();
  }

  Future<void> _onSeriesChanged(SeriesOption e) async {
    setState(() => _seriesId = e.id);
    await _loadStudySubjects();
  }

  Future<void> _loadStudySubjects() async {
    final seriesId = _seriesId;
    if (!Env.hasSupabase || seriesId == null) {
      if (mounted) {
        setState(() {
          _studySubjects = const [];
          _strongSubjectIds.clear();
          _weakSubjectIds.clear();
          _interestSubjectIds.clear();
        });
      }
      return;
    }
    setState(() => _busyStudy = true);
    try {
      final subjectRows = await Supabase.instance.client.rpc(
        'list_signup_subjects',
        params: {'p_level_id': _levelId, 'p_series_id': seriesId},
      );
      final next = (subjectRows as List)
          .map(
            (e) => LearningSubject(
              id: '${e['id']}',
              code: '${e['code']}',
              label: '${e['label']}',
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _studySubjects = next;
        _strongSubjectIds = _strongSubjectIds.intersection(
          next.map((e) => e.id).toSet(),
        );
        _weakSubjectIds = _weakSubjectIds.intersection(
          next.map((e) => e.id).toSet(),
        );
        _interestSubjectIds = _interestSubjectIds.intersection(
          next.map((e) => e.id).toSet(),
        );
        _busyStudy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _studySubjects = const [];
        _busyStudy = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (name.isEmpty) {
      ModernSnackbar.show(context, 'Ton nom est requis.', success: false);
      return;
    }
    final phoneError = phoneValidationMessage(
      countryCode: 'TG',
      phone: _phoneCtrl.text,
    );
    if (phoneError != null) {
      ModernSnackbar.show(context, phoneError, success: false);
      return;
    }
    if (_levelId == null || _seriesId == null) {
      ModernSnackbar.show(
        context,
        'Choisis une classe et une série avant de créer ton compte.',
        success: false,
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ModernSnackbar.show(
        context,
        'Entre une adresse email valide.',
        success: false,
      );
      return;
    }
    if (pass.length < 8) {
      ModernSnackbar.show(
        context,
        'Choisis un mot de passe d’au moins 8 caractères.',
        success: false,
      );
      return;
    }
    if (pass != _confirmCtrl.text) {
      ModernSnackbar.show(
        context,
        'Les mots de passe ne correspondent pas.',
        success: false,
      );
      return;
    }
    if (!_legalAccepted) {
      ModernSnackbar.show(
        context,
        'Accepte les Conditions et la Politique de confidentialité.',
        success: false,
      );
      return;
    }
    if (!_aiEnabled) {
      ModernSnackbar.show(
        context,
        'Active aussi le consentement Personnalisation et amélioration IA pour continuer.',
        success: false,
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _profileSetup.savePendingRegistrationDraft(
        email: email,
        fullName: name,
        schoolName: _schoolCtrl.text,
        whatsappPhone: _phoneCtrl.text,
        levelId: _levelId,
        seriesId: _seriesId,
        primaryGoal: _primaryGoal,
        targetExam: _targetExam,
        studyRhythm: _studyRhythm,
        strongSubjectIds: _strongSubjectIds.toList(growable: false),
        weakSubjectIds: _weakSubjectIds.toList(growable: false),
        interestSubjectIds: _interestSubjectIds.toList(growable: false),
        acceptLegal: _legalAccepted,
        enableAi: _aiEnabled,
      );
      final outcome = await widget.repository.signUpWithEmail(email, pass);
      if (!outcome.accountCreated) {
        throw StateError('Le compte n’a pas pu être créé. Réessaie.');
      }
      if (outcome.signedIn) {
        await _profileSetup.completeSignupProfile(
          fullName: name,
          schoolName: _schoolCtrl.text,
          whatsappPhone: _phoneCtrl.text,
          levelId: _levelId,
          seriesId: _seriesId,
          primaryGoal: _primaryGoal,
          targetExam: _targetExam,
          studyRhythm: _studyRhythm,
          strongSubjectIds: _strongSubjectIds.toList(growable: false),
          weakSubjectIds: _weakSubjectIds.toList(growable: false),
          interestSubjectIds: _interestSubjectIds.toList(growable: false),
          acceptLegal: _legalAccepted,
          enableAi: _aiEnabled,
        );
        await _profileSetup.clearPendingRegistrationDraft();
      } else {
        throw StateError(
          'Le compte existe, mais la session n’a pas démarré. Reconnecte-toi pour terminer.',
        );
      }
      if (!mounted) return;
      if (outcome.signedIn) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SignupBridgePage(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ModernSnackbar.show(context, userErrorMessage(e), success: false);
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _next() {
    if (_step == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        ModernSnackbar.show(context, 'Ton nom est requis.', success: false);
        return;
      }
      final phoneError = phoneValidationMessage(
        countryCode: 'TG',
        phone: _phoneCtrl.text,
      );
      if (phoneError != null) {
        ModernSnackbar.show(context, phoneError, success: false);
        return;
      }
    }
    if (_step == 1 && (_levelId == null || _seriesId == null)) {
      ModernSnackbar.show(
        context,
        'Choisis une classe et une série avant de continuer.',
        success: false,
      );
      return;
    }
    if (_step < 3) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AuthBackGuard(
      canStepBack: _step > 0,
      onStepBack: _back,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: RuachAppBar(
          title: 'Créer un compte',
          showBack: false,
          leading: IconButton(
            icon: const Icon(PhosphorIconsRegular.arrowLeft),
            onPressed: _step == 0 ? () => Navigator.of(context).pop() : _back,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: RuachSpace.s4),
              _stepIndicator(s.primary),
              const SizedBox(height: RuachSpace.s6),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RuachSpace.s6,
                  ),
                  child: SingleChildScrollView(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) {
                        final curve = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        );
                        return FadeTransition(
                          opacity: curve,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(.06, .02),
                              end: Offset.zero,
                            ).animate(curve),
                            child: ScaleTransition(scale: curve, child: child),
                          ),
                        );
                      },
                      child: switch (_step) {
                        0 => _buildStepName(s),
                        1 => _buildStepClass(),
                        2 => _buildStepStudyProfile(s),
                        _ => _buildStepAccount(s),
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: RuachSpace.s6,
                  right: RuachSpace.s6,
                  bottom: bottomInset > 0
                      ? bottomInset + RuachSpace.s4
                      : RuachSpace.s4,
                  top: RuachSpace.s3,
                ),
                child: _buildBottomNav(s.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator(Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 4; i++) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= _step
                  ? primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            alignment: Alignment.center,
            child: i < _step
                ? const Icon(
                    PhosphorIconsRegular.check,
                    size: 16,
                    color: Colors.white,
                  )
                : Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: i <= _step
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
          if (i < 3)
            Container(
              width: 40,
              height: 2,
              color: i < _step
                  ? primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
        ],
      ],
    );
  }

  Widget _buildStepName(ColorScheme s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'On commence par toi.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: s.onSurface,
          ),
        ),
        const SizedBox(height: RuachSpace.s1),
        Text(
          'Nom, école et téléphone pour finaliser ton entrée sans friction.',
          style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: RuachSpace.s5),
        RuachInput(
          controller: _nameCtrl,
          hint: 'Nom complet',
          prefixIcon: const Icon(PhosphorIconsRegular.user, size: 20),
        ),
        const SizedBox(height: RuachSpace.s4),
        TogoPhoneInput(controller: _phoneCtrl, label: 'Téléphone'),
        const SizedBox(height: RuachSpace.s4),
        Text(
          'École',
          style: TextStyle(fontWeight: FontWeight.w600, color: s.onSurface),
        ),
        const SizedBox(height: RuachSpace.s2),
        _buildSchoolAutocomplete(isDark, s),
      ],
    );
  }

  Widget _buildSchoolAutocomplete(bool isDark, ColorScheme s) {
    return Autocomplete<String>(
      optionsBuilder: (v) {
        if (v.text.isEmpty) return _schoolSuggestions;
        final q = v.text.toLowerCase();
        final matches = _schoolSuggestions
            .where((n) => n.toLowerCase().contains(q))
            .toList();
        // Always include the typed text so user can create a new school
        if (v.text.trim().isNotEmpty &&
            !matches.any(
              (n) => n.toLowerCase() == v.text.trim().toLowerCase(),
            )) {
          matches.insert(0, v.text.trim());
        }
        return matches;
      },
      onSelected: (val) {
        _schoolCtrl.text = val;
        FocusManager.instance.primaryFocus?.unfocus();
      },
      fieldViewBuilder: (ctx, controller, focusNode, onSubmit) {
        // Sync with our controller
        controller.text = _schoolCtrl.text;
        controller.selection = TextSelection.collapsed(
          offset: controller.text.length,
        );
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) {
            if (_schoolCtrl.text != value) {
              _schoolCtrl.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            }
          },
          onSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            hintText: 'Recherche ou saisis ton école...',
            prefixIcon: const Icon(PhosphorIconsRegular.buildings, size: 20),
            suffixIcon: _loadingSchools
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(PhosphorIconsRegular.caretDown, size: 16),
            filled: true,
            fillColor: isDark ? RuachColors.ink400 : RuachColors.cream100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RuachRadius.md),
              borderSide: BorderSide(
                color: isDark ? RuachColors.ink500 : RuachColors.cream200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RuachRadius.md),
              borderSide: BorderSide(
                color: isDark ? RuachColors.ink500 : RuachColors.cream200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RuachRadius.md),
              borderSide: const BorderSide(
                color: RuachColors.gold500,
                width: 2,
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (ctx, onSelect, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(RuachRadius.md),
            color: isDark ? RuachColors.ink400 : RuachColors.cream50,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final opt = options.elementAt(i);
                  final isNew = !_schoolSuggestions.any(
                    (s) => s.toLowerCase() == opt.toLowerCase(),
                  );
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isNew
                          ? PhosphorIconsRegular.plusCircle
                          : PhosphorIconsRegular.buildings,
                      size: 18,
                      color: isNew ? RuachColors.gold500 : s.onSurfaceVariant,
                    ),
                    title: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isNew ? FontWeight.w600 : FontWeight.w400,
                        color: s.onSurface,
                      ),
                    ),
                    subtitle: isNew
                        ? Text(
                            'Utiliser cette saisie',
                            style: TextStyle(
                              fontSize: 11,
                              color: RuachColors.gold500,
                            ),
                          )
                        : null,
                    onTap: () => onSelect(opt),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepClass() {
    final s = Theme.of(context).colorScheme;
    // Error state
    if (_classError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsRegular.wifiSlash,
              size: 48,
              color: s.onSurfaceVariant,
            ),
            const SizedBox(height: RuachSpace.s3),
            Text(
              _classError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: s.onSurfaceVariant),
            ),
            const SizedBox(height: RuachSpace.s4),
            RuachOutlineButton(
              label: 'Réessayer',
              icon: PhosphorIconsRegular.arrowsClockwise,
              onPressed: () {
                setState(() {
                  _classError = null;
                  _levels = const [];
                });
                _loadClassData();
              },
            ),
          ],
        ),
      );
    }
    // Loading state
    if (_levels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const RuachLoader(label: 'Chargement des classes')],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisis ta filière et ta classe',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: s.onSurface,
          ),
        ),
        const SizedBox(height: RuachSpace.s1),
        Text(
          'Tu pourras changer plus tard dans tes paramètres.',
          style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: RuachSpace.s5),
        ClassSelectionForm(
          levels: _levels,
          levelId: _levelId,
          series: _series,
          seriesId: _seriesId,
          busy: _busyClass,
          onLevelChanged: _onLevelChanged,
          onSeriesChanged: (e) => _onSeriesChanged(e),
          onSave: () {},
          showApplyButton: false,
          showSectionTitle: false,
        ),
      ],
    );
  }

  Widget _buildStepStudyProfile(ColorScheme s) {
    return Column(
      key: const ValueKey('study'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ton profil d’étude',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: s.onSurface,
          ),
        ),
        const SizedBox(height: RuachSpace.s1),
        Text(
          'Aide-nous à personnaliser l’expérience. Cette étape reste flexible.',
          style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: RuachSpace.s4),
        _buildChoiceGroup(
          label: 'Objectif principal',
          value: _primaryGoal,
          values: const [
            ('excel', 'Exceller'),
            ('catch_up', 'Rattraper'),
            ('prepare_exam', 'Préparer examen'),
          ],
          onChanged: (v) => setState(() => _primaryGoal = v),
        ),
        const SizedBox(height: RuachSpace.s3),
        _buildChoiceGroup(
          label: 'Cible d’examen',
          value: _targetExam,
          values: const [
            ('bac1', 'BAC 1'),
            ('bac2', 'BAC 2'),
            ('pass_class', 'Passer la classe'),
            ('contest', 'Concours'),
          ],
          onChanged: (v) => setState(() => _targetExam = v),
        ),
        const SizedBox(height: RuachSpace.s3),
        _buildChoiceGroup(
          label: 'Rythme d’étude',
          value: _studyRhythm,
          values: const [
            ('daily', 'Chaque jour'),
            ('3x_week', '3x / semaine'),
            ('weekend', 'Week-end'),
          ],
          onChanged: (v) => setState(() => _studyRhythm = v),
        ),
        const SizedBox(height: RuachSpace.s4),
        _buildSubjectSignalBlock(
          title: 'Matières fortes',
          hint: 'Ce que tu maîtrises déjà',
          selected: _strongSubjectIds,
          tone: s.primary,
        ),
        const SizedBox(height: RuachSpace.s3),
        _buildSubjectSignalBlock(
          title: 'Matières à renforcer',
          hint: 'Là où tu veux plus d’aide',
          selected: _weakSubjectIds,
          tone: RuachColors.warning400,
        ),
        const SizedBox(height: RuachSpace.s3),
        _buildSubjectSignalBlock(
          title: 'Centres d’intérêt',
          hint: 'Optionnel',
          selected: _interestSubjectIds,
          tone: RuachColors.gold500,
        ),
      ],
    );
  }

  Widget _buildStepAccount(ColorScheme s) {
    return Column(
      key: const ValueKey('account'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crée ton compte',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: s.onSurface,
          ),
        ),
        const SizedBox(height: RuachSpace.s1),
        Text(
          'Email et mot de passe pour te connecter.',
          style: TextStyle(color: s.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: RuachSpace.s5),
        RuachInput(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          hint: 'Email',
          prefixIcon: const Icon(PhosphorIconsRegular.envelope, size: 20),
        ),
        const SizedBox(height: RuachSpace.s3),
        RuachInput(
          controller: _passCtrl,
          obscure: _obscure,
          hint: 'Mot de passe',
          prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 20),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? PhosphorIconsRegular.eyeSlash
                  : PhosphorIconsRegular.eye,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: RuachSpace.s3),
        RuachInput(
          controller: _confirmCtrl,
          obscure: _obscureConfirm,
          hint: 'Confirmer mot de passe',
          prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 20),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            icon: Icon(
              _obscureConfirm
                  ? PhosphorIconsRegular.eyeSlash
                  : PhosphorIconsRegular.eye,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: RuachSpace.s4),
        SignupConsentCard(
          legalAccepted: _legalAccepted,
          aiEnabled: _aiEnabled,
          onLegalChanged: (v) => setState(() => _legalAccepted = v),
          onAiChanged: (v) => setState(() => _aiEnabled = v),
          onOpenTerms: () => _openLegal('terms'),
          onOpenPrivacy: () => _openLegal('privacy'),
        ),
      ],
    );
  }

  void _openLegal(String type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            LegalDocumentPage(docType: type, showAcceptAction: false),
      ),
    );
  }

  Widget _buildBottomNav(Color primary) {
    return Row(
      children: [
        if (_step > 0)
          Expanded(
            child: RuachOutlineButton(label: 'Précédent', onPressed: _back),
          ),
        if (_step > 0) const SizedBox(width: RuachSpace.s3),
        Expanded(
          child: RuachButton(
            label: _step < 3 ? 'Continuer' : 'Créer mon compte',
            loading: _loading,
            onPressed: _step < 3 ? _next : _submit,
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceGroup({
    required String label,
    required String? value,
    required List<(String, String)> values,
    required ValueChanged<String> onChanged,
  }) {
    final s = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: s.onSurface),
        ),
        const SizedBox(height: RuachSpace.s2),
        Wrap(
          spacing: RuachSpace.s2,
          runSpacing: RuachSpace.s2,
          children: values.map((entry) {
            final selected = value == entry.$1;
            return ChoiceChip(
              label: Text(entry.$2),
              selected: selected,
              onSelected: (_) => onChanged(entry.$1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectSignalBlock({
    required String title,
    required String hint,
    required Set<String> selected,
    required Color tone,
  }) {
    final s = Theme.of(context).colorScheme;
    if (_busyStudy) {
      return const Center(child: RuachLoader(label: 'Chargement des matières'));
    }
    if (_studySubjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(RuachSpace.s3),
        decoration: BoxDecoration(
          color: s.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RuachRadius.lg),
        ),
        child: Text(
          'Aucune matière ciblable pour cette série pour l’instant.',
          style: TextStyle(color: s.onSurfaceVariant, fontSize: 12),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: s.onSurface),
        ),
        const SizedBox(height: RuachSpace.s1),
        Text(hint, style: TextStyle(color: s.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: RuachSpace.s2),
        Wrap(
          spacing: RuachSpace.s2,
          runSpacing: RuachSpace.s2,
          children: _studySubjects.map((subject) {
            final isOn = selected.contains(subject.id);
            return FilterChip(
              label: Text(subject.label),
              selected: isOn,
              selectedColor: tone.withValues(alpha: .16),
              checkmarkColor: tone,
              onSelected: (_) => setState(() {
                if (isOn) {
                  selected.remove(subject.id);
                } else {
                  selected.add(subject.id);
                }
              }),
            );
          }).toList(),
        ),
      ],
    );
  }
}
