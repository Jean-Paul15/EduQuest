import 'package:eduquest/features/auth/data/auth_repository.dart';
import 'package:eduquest/features/class_selection/data/class_selection_repository.dart';
import 'package:eduquest/shared/config/env.dart';
import 'package:eduquest/shared/data/local_json_cache.dart';
import 'package:eduquest/shared/validation/phone_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupState {
  const ProfileSetupState({
    required this.fullName,
    required this.levelId,
    required this.seriesId,
    required this.countryCode,
    required this.whatsappPhone,
    required this.complete,
  });
  final String fullName;
  final String? levelId;
  final String? seriesId;
  final String countryCode;
  final String whatsappPhone;
  final bool complete;

  bool get needsFullName => fullName.trim().isEmpty;
  bool get needsPhone => whatsappPhone.trim().isEmpty;
  bool get needsLevel => levelId == null;
  bool get needsSeries => seriesId == null;
  bool get needsSchooling => needsLevel || needsSeries;
}

class ProfileSetupRepository {
  static const _pendingRegistrationKey = 'register:draft';
  final _auth = AuthRepository();
  final _classRepo = ClassSelectionRepository();
  final _local = LocalJsonCache();

  Future<ProfileSetupState> load() => _load(applyDraft: true);

  Future<ProfileSetupState> _load({required bool applyDraft}) async {
    if (!Env.hasSupabase || _auth.currentUser == null) {
      return const ProfileSetupState(
        fullName: '',
        levelId: null,
        seriesId: null,
        countryCode: 'TG',
        whatsappPhone: '',
        complete: false,
      );
    }
    final uid = _auth.currentUser!.id;
    try {
      await _ensureProfileRow();
      if (applyDraft) await applyPendingRegistrationDraft();
      final row = await Supabase.instance.client
          .from('profiles')
          .select(
            'full_name,education_level_id,series_id,whatsapp_phone,country:countries(code)',
          )
          .eq('id', uid)
          .maybeSingle();
      final fullName = row?['full_name']?.toString().trim() ?? '';
      final levelId = row?['education_level_id']?.toString();
      final seriesId = row?['series_id']?.toString();
      final phone = row?['whatsapp_phone']?.toString().trim() ?? '';
      final countryCode =
          (row?['country'] as Map?)?['code']?.toString() ?? 'TG';
      final complete =
          fullName.isNotEmpty &&
          levelId != null &&
          seriesId != null &&
          phone.isNotEmpty;
      final out = ProfileSetupState(
        fullName: fullName,
        levelId: levelId,
        seriesId: seriesId,
        countryCode: countryCode,
        whatsappPhone: phone,
        complete: complete,
      );
      await _writeLocal(uid, out);
      return out;
    } catch (_) {
      final cached = await _readLocal(uid);
      if (cached?.complete == true) return cached!;
      rethrow;
    }
  }

  Future<ProfileSetupState?> loadCached() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return null;
    return _readLocal(uid);
  }

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
    await _local.writeList(_pendingRegistrationKey, [
      {
        'email': email.trim().toLowerCase(),
        'full_name': fullName.trim(),
        'school_name': schoolName.trim(),
        'whatsapp_phone': normalizePhone(whatsappPhone).replaceAll('+', ''),
        'education_level_id': levelId,
        'series_id': seriesId,
        'primary_goal': primaryGoal,
        'target_exam': targetExam,
        'study_rhythm': studyRhythm,
        'strong_subject_ids': strongSubjectIds,
        'weak_subject_ids': weakSubjectIds,
        'interest_subject_ids': interestSubjectIds,
        'accept_legal': acceptLegal,
        'enable_ai': enableAi,
      },
    ]);
  }

  Future<bool> applyPendingRegistrationDraft() async {
    final uid = _auth.currentUser?.id;
    final currentEmail = _auth.currentUser?.email?.trim().toLowerCase();
    if (!Env.hasSupabase || uid == null || currentEmail == null) return false;
    final rows = await _local.readList(_pendingRegistrationKey);
    if (rows == null || rows.isEmpty) return false;
    final draft = rows.first;
    final draftEmail = draft['email']?.toString().trim().toLowerCase();
    if (draftEmail == null ||
        draftEmail.isEmpty ||
        draftEmail != currentEmail) {
      return false;
    }
    try {
      if (draft['accept_legal'] != true) return false;
      await completeSignupProfile(
        fullName: draft['full_name']?.toString() ?? '',
        schoolName: draft['school_name']?.toString() ?? '',
        whatsappPhone: draft['whatsapp_phone']?.toString() ?? '',
        levelId: draft['education_level_id']?.toString(),
        seriesId: draft['series_id']?.toString(),
        primaryGoal: draft['primary_goal']?.toString(),
        targetExam: draft['target_exam']?.toString(),
        studyRhythm: draft['study_rhythm']?.toString(),
        strongSubjectIds: _readIdList(draft['strong_subject_ids']),
        weakSubjectIds: _readIdList(draft['weak_subject_ids']),
        interestSubjectIds: _readIdList(draft['interest_subject_ids']),
        acceptLegal: true,
        enableAi: draft['enable_ai'] == true,
      );
      await _local.removeByPrefix(_pendingRegistrationKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearPendingRegistrationDraft() async {
    await _local.removeByPrefix(_pendingRegistrationKey);
  }

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
    final uid = _auth.currentUser?.id;
    if (!Env.hasSupabase || uid == null) {
      return const ProfileSetupState(
        fullName: '',
        levelId: null,
        seriesId: null,
        countryCode: 'TG',
        whatsappPhone: '',
        complete: false,
      );
    }
    final normalizedPhone = _serverPhone(whatsappPhone);
    final response = await Supabase.instance.client.rpc(
      'complete_student_signup_profile',
      params: {
        'p_payload': {
          'full_name': fullName.trim(),
          'whatsapp_phone': normalizedPhone,
          'education_level_id': levelId,
          'series_id': seriesId,
          'school_name': schoolName.trim(),
          'primary_goal': primaryGoal,
          'target_exam': targetExam,
          'study_rhythm': studyRhythm,
          'strong_subject_ids': strongSubjectIds,
          'weak_subject_ids': weakSubjectIds,
          'interest_subject_ids': interestSubjectIds,
          'accept_legal': acceptLegal,
          'enable_ai': enableAi,
        },
      },
    );
    final out = Map<String, dynamic>.from(response as Map);
    if (out['success'] != true) {
      throw StateError('${out['message'] ?? 'Profil non finalisé.'}');
    }
    final current = await _load(applyDraft: false);
    if (current.levelId != null) {
      await _classRepo.saveLocalSelection(current.levelId!, current.seriesId);
    }
    return current;
  }

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
    final payload = <String, dynamic>{
      if (fullName != null) 'full_name': fullName.trim(),
      if (schoolName != null) 'school_name': schoolName.trim(),
      if (whatsappPhone != null) 'whatsapp_phone': _serverPhone(whatsappPhone),
      if (levelId != null) 'education_level_id': levelId,
      if (seriesId != null) 'series_id': seriesId,
      if (primaryGoal != null) 'primary_goal': primaryGoal,
      if (targetExam != null) 'target_exam': targetExam,
      if (studyRhythm != null) 'study_rhythm': studyRhythm,
      if (strongSubjectIds != null) 'strong_subject_ids': strongSubjectIds,
      if (weakSubjectIds != null) 'weak_subject_ids': weakSubjectIds,
      if (interestSubjectIds != null)
        'interest_subject_ids': interestSubjectIds,
    };
    final response = await Supabase.instance.client.rpc(
      'update_student_profile',
      params: {'p_payload': payload},
    );
    final out = Map<String, dynamic>.from(response as Map);
    if (out['success'] != true) throw StateError('Profil non mis à jour.');
    final current = await _load(applyDraft: false);
    if (current.levelId != null) {
      await _classRepo.saveLocalSelection(current.levelId!, current.seriesId);
    }
    return current;
  }

  Future<void> saveLearningPreferences({
    String? primaryGoal,
    String? targetExam,
    String? studyRhythm,
    List<String> strongSubjectIds = const [],
    List<String> weakSubjectIds = const [],
    List<String> interestSubjectIds = const [],
  }) async {
    final current = await _load(applyDraft: false);
    await finalizeProfile(
      levelId: current.levelId,
      seriesId: current.seriesId,
      primaryGoal: primaryGoal,
      targetExam: targetExam,
      studyRhythm: studyRhythm,
      strongSubjectIds: strongSubjectIds,
      weakSubjectIds: weakSubjectIds,
      interestSubjectIds: interestSubjectIds,
    );
  }

  Future<void> saveFullName(String name) async {
    final current = await _load(applyDraft: false);
    await finalizeProfile(
      fullName: name,
      levelId: current.levelId,
      seriesId: current.seriesId,
    );
  }

  Future<void> saveWhatsappPhone(String phone) async {
    final current = await _load(applyDraft: false);
    await finalizeProfile(
      whatsappPhone: phone,
      levelId: current.levelId,
      seriesId: current.seriesId,
    );
  }

  Future<void> _ensureProfileRow() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return;
    final p = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('id', uid)
        .maybeSingle();
    if (p != null) return;
    final tg = await Supabase.instance.client
        .from('countries')
        .select('id')
        .eq('code', 'TG')
        .maybeSingle();
    await Supabase.instance.client.from('profiles').insert({
      'id': uid,
      'role': 'student',
      'country_id': tg?['id'],
    });
  }

  List<String> _readIdList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => '$e').where((e) => e.isNotEmpty).toList();
  }

  String _serverPhone(String phone) {
    final digits = normalizePhone(phone).replaceAll('+', '');
    return digits.length == 8 ? '228$digits' : digits;
  }

  Future<void> _writeLocal(String uid, ProfileSetupState s) async {
    await _local.writeList('profile:setup:$uid', [
      {
        'full_name': s.fullName,
        'education_level_id': s.levelId,
        'series_id': s.seriesId,
        'country_code': s.countryCode,
        'whatsapp_phone': s.whatsappPhone,
        'complete': s.complete,
      },
    ]);
  }

  Future<ProfileSetupState?> _readLocal(String uid) async {
    final rows = await _local.readList('profile:setup:$uid');
    if (rows == null || rows.isEmpty) return null;
    final r = rows.first;
    final fullName = r['full_name']?.toString() ?? '';
    final levelId = r['education_level_id']?.toString();
    final seriesId = r['series_id']?.toString();
    final countryCode = r['country_code']?.toString() ?? 'TG';
    final phone = r['whatsapp_phone']?.toString() ?? '';
    final complete = r['complete'] == true;
    return ProfileSetupState(
      fullName: fullName,
      levelId: levelId,
      seriesId: seriesId,
      countryCode: countryCode,
      whatsappPhone: phone,
      complete: complete,
    );
  }
}
