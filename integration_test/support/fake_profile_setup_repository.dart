import 'package:eduquest/features/profile/data/profile_setup_repository.dart';

class FakeProfileSetupRepository extends ProfileSetupRepository {
  FakeProfileSetupRepository(this.state);

  ProfileSetupState state;
  String? savedPhone;
  Map<String, dynamic>? pendingDraft;
  bool signupCompleted = false;
  bool draftCleared = false;

  @override
  Future<ProfileSetupState> load() async => state;

  @override
  Future<ProfileSetupState?> loadCached() async => state;

  @override
  Future<void> savePendingRegistrationDraft({
    required String email,
    required String fullName,
    required String schoolName,
    required String whatsappPhone,
    required String? levelId,
    required String? seriesId,
    String? primaryGoal,
    String? targetExam,
    String? studyRhythm,
    List<String> strongSubjectIds = const [],
    List<String> weakSubjectIds = const [],
    List<String> interestSubjectIds = const [],
    bool acceptLegal = false,
    bool enableAi = false,
  }) async {
    pendingDraft = {
      'email': email,
      'fullName': fullName,
      'acceptLegal': acceptLegal,
      'enableAi': enableAi,
    };
  }

  @override
  Future<ProfileSetupState> completeSignupProfile({
    required String fullName,
    required String schoolName,
    required String whatsappPhone,
    required String? levelId,
    required String? seriesId,
    String? primaryGoal,
    String? targetExam,
    String? studyRhythm,
    List<String> strongSubjectIds = const [],
    List<String> weakSubjectIds = const [],
    List<String> interestSubjectIds = const [],
    required bool acceptLegal,
    required bool enableAi,
  }) async {
    signupCompleted = acceptLegal;
    return _save(fullName, whatsappPhone, levelId, seriesId);
  }

  @override
  Future<void> clearPendingRegistrationDraft() async {
    draftCleared = true;
    pendingDraft = null;
  }

  @override
  Future<ProfileSetupState> finalizeProfile({
    String? fullName,
    String? schoolName,
    String? whatsappPhone,
    String? levelId,
    String? seriesId,
    String? primaryGoal,
    String? targetExam,
    String? studyRhythm,
    List<String>? strongSubjectIds,
    List<String>? weakSubjectIds,
    List<String>? interestSubjectIds,
  }) async {
    savedPhone = whatsappPhone;
    return _save(fullName, whatsappPhone, levelId, seriesId);
  }

  ProfileSetupState _save(
    String? fullName,
    String? whatsappPhone,
    String? levelId,
    String? seriesId,
  ) {
    state = ProfileSetupState(
      fullName: fullName?.trim().isEmpty == false
          ? fullName!.trim()
          : state.fullName,
      levelId: levelId ?? state.levelId,
      seriesId: seriesId ?? state.seriesId,
      countryCode: state.countryCode,
      whatsappPhone: whatsappPhone?.trim().isEmpty == false
          ? whatsappPhone!.trim()
          : state.whatsappPhone,
      complete: true,
    );
    return state;
  }
}
