/// Canonical names for Supabase tables, RPC functions, storage keys, and cache keys.
/// §11.6: No magic strings — every name used by multiple files lives here.
class AppTables {
  AppTables._();
  // ─── Core taxonomy ───
  static const countries = 'countries';
  static const educationLevels = 'education_levels';
  static const series = 'series';
  static const subjects = 'subjects';
  static const seriesSubjects = 'series_subjects';
  // ─── Users & profiles ───
  static const profiles = 'profiles';
  static const profileLevelChanges = 'profile_level_changes';
  static const userDeviceSessions = 'user_device_sessions';
  // ─── Content ───
  static const chapters = 'chapters';
  static const resources = 'resources';
  static const quizzes = 'quizzes';
  static const quizQuestions = 'quiz_questions';
  static const questionGroups = 'question_groups';
  static const examPapers = 'exam_papers';
  static const liveClasses = 'live_classes';
  static const orientationSessions = 'orientation_sessions';
  // ─── Access & tickets ───
  static const ticketProducts = 'ticket_products';
  static const ticketCodes = 'ticket_codes';
  static const accessCampaigns = 'access_campaigns';
  static const accessGrants = 'access_grants';
  static const partnerSchools = 'partner_schools';
  static const partnerContracts = 'partner_contracts';
  // ─── Engagement ───
  static const contests = 'contests';
  static const contestEntries = 'contest_entries';
  static const events = 'events';
  static const eventRegistrations = 'event_registrations';
  static const eventPublicTickets = 'event_public_tickets';
  // ─── Referral ───
  static const referralLinks = 'referral_links';
  static const referralUses = 'referral_uses';
  static const referralRewardEvents = 'referral_reward_events';
  // ─── Surveys ───
  static const surveys = 'surveys';
  static const surveyQuestions = 'survey_questions';
  static const surveyAnswers = 'survey_answers';
  // ─── Marketplace ───
  static const marketplaceItems = 'marketplace_items';
  // ─── Gamification ───
  static const gamificationProfiles = 'gamification_profiles';
  static const dailyQuests = 'daily_quests';
  static const questCompletions = 'quest_completions';
  static const antiCheatRules = 'anti_cheat_rules';
  static const weeklyLeaderboards = 'weekly_leaderboards';
  static const monthlyRewardPolicies = 'monthly_reward_policies';
  static const monthlyRewardResults = 'monthly_reward_results';
  // ─── Notifications ───
  static const notificationPreferences = 'notification_preferences';
  static const notificationCampaigns = 'notification_campaigns';
  // ─── Progress & analytics ───
  static const learningProgress = 'learning_progress';
  static const appEvents = 'app_events';
  static const analyticsConsentPreferences = 'analytics_consent_preferences';
  static const analyticsFailuresArchive = 'analytics_failures_archive';
  static const dailyUserLearningStats = 'daily_user_learning_stats';
  static const dailyContentUsage = 'daily_content_usage';
  static const aiChatThreads = 'ai_chat_threads';
  static const aiChatMessages = 'ai_chat_messages';
  // ─── Config & legal ───
  static const appConfig = 'app_config';
  static const legalDocuments = 'legal_documents';
  static const userLegalConsents = 'user_legal_consents';
  static const dataRetentionPolicies = 'data_retention_policies';
  static const complianceAuditLogs = 'compliance_audit_logs';
  static const dataDeletionRequests = 'data_deletion_requests';
  // ─── Backoffice ───
  static const backofficeRoles = 'backoffice_roles';
  static const backofficePermissions = 'backoffice_permissions';
  static const backofficeRolePermissions = 'backoffice_role_permissions';
  static const backofficeNavSections = 'backoffice_nav_sections';
  static const backofficeRoleNavSections = 'backoffice_role_nav_sections';
  static const backofficeUserRoles = 'backoffice_user_roles';
  // ─── Misc ───
  static const webSessionHandoffs = 'web_session_handoffs';
  static const onboardingTicketCampaigns = 'onboarding_ticket_campaigns';
}

/// Canonical RPC function names.
class AppRpc {
  AppRpc._();
  static const claimDailyCheckin = 'claim_daily_checkin';
  static const claimDailyQuest = 'claim_daily_quest';
  static const claimDeviceSession = 'claim_device_session';
  static const isDeviceSessionValid = 'is_device_session_valid';
  static const ensureReferralCode = 'ensure_referral_code';
  static const resolveAccessScope = 'resolve_access_scope';
  static const activateTicketCode = 'activate_ticket_code';
  static const buildWeeklyLeaderboard = 'build_weekly_leaderboard';
  static const joinContest = 'join_contest';
  static const joinEvent = 'join_event';
  static const cancelContestRegistration = 'cancel_contest_registration';
  static const cancelEventRegistration = 'cancel_event_registration';
  static const submitSurveyBulk = 'submit_survey_bulk';
  static const submitSingleSurvey = 'submit_single_survey';
  static const createCheckoutSession = 'create_checkout_session';
  static const confirmCheckoutPayment = 'confirm_checkout_payment';
  static const claimReferralReward = 'claim_referral_reward';
  static const registerPushSubscription = 'register_push_subscription';
  static const markNotificationsRead = 'mark_notifications_read';
  static const getOrCreateDeviceSession = 'get_or_create_device_session';
  static const fetchClassStructure = 'fetch_class_structure';
  static const ingestAppEvents = 'ingest_app_events';
  static const aiGetSecret = 'ai_get_secret';
  static const refreshDailyAnalyticsRollups = 'refresh_daily_analytics_rollups';
}

/// SharedPreferences and flutter_secure_storage keys.
class AppStorageKeys {
  AppStorageKeys._();
  // flutter_secure_storage
  static const encryptionKey = 'media_encryption_key';
  static const sessionToken = 'session_token';
  // shared_preferences
  static const themeMode = 'theme_mode';
  static const locale = 'locale';
  static const lastSyncTimestamp = 'last_sync_timestamp';
  static const offlinePreference = 'offline_preference';
  static const onboardingSeen = 'onboarding_seen';
  static const lastUpdateGateCheck = 'last_update_gate_check';
  static const analyticsSessionId = 'analytics_session_id';
  static const featureFlags = 'feature_flags';
  // SQLite local databases
  static const syncDbName = 'eduquest_sync.db';
  static const cacheDbName = 'eduquest_cache.db';
}

/// Cache key prefixes for LocalJsonCache / media cache.
class AppCacheKeys {
  AppCacheKeys._();
  static const gamState = 'gam:state';
  static const gamQuests = 'gam:quests';
  static const homeSnapshot = 'home:snapshot';
  static const learningCatalog = 'learning:catalog';
  static const learningScope = 'learning:scope';
  static const engagementFeed = 'engagement:feed';
  static const accessState = 'access:state';
  static const profileState = 'profile:state';
  static const appLinks = 'app:links';
  static const featureFlags = 'app:feature_flags';
  static const notifications = 'notifications:list';
}

/// Sync queue operation types.
class SyncOp {
  SyncOp._();
  static const insert = 'INSERT';
  static const update = 'UPDATE';
  static const delete = 'DELETE';
  static const rpc = 'RPC';
}

/// Sync status values.
class SyncStatus {
  SyncStatus._();
  static const pending = 'pending';
  static const inProgress = 'in_progress';
  static const failed = 'failed';
  static const done = 'done';
}

/// Offline-first configuration constants.
class OfflineConfig {
  OfflineConfig._();
  static const maxRetries = 5;
  static const retryDelaysSeconds = [1, 2, 4, 8, 16];
  static const doneItemTtlHours = 48;
  static const failedItemTtlDays = 7;
  static const offlineAuthGraceDays = 7;
  static const connectivityProbeTimeoutSeconds = 3;
  static const connectivityDebounceSeconds = 10;
  static const connectivityConfirmThreshold = 3;
  static const connectivityRetryDelaySeconds = 5;
  static const backgroundSyncIntervalMinutes = 15;
  static const pollSyncQueueSeconds = 30;
  static const imageCacheTtlDays = 30;
  static const maxTotalCacheBytes = 5368709120; // 5 GB (images + PDFs + videos)
}
