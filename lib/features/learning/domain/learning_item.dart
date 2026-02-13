class LearningItem {
  const LearningItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.url,
    this.count,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? url;
  final int? count;
}
