class EngagementItem {
  const EngagementItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startsAt,
    this.requiredTicketType,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime startsAt;
  final String? requiredTicketType;
}
