class AnalyticsConsentState {
  const AnalyticsConsentState({
    required this.personalizationAi,
    required this.aiImprovement,
  });

  final bool personalizationAi;
  final bool aiImprovement;

  bool get allowsLearningAnalytics => personalizationAi || aiImprovement;
}
