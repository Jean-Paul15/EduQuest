class EngagementDetail {
  const EngagementDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredTicketType,
    required this.startsAt,
    this.endsAt,
    this.venue,
    this.externalUrl,
    this.isInPerson,
  });

  final String id;
  final String title;
  final String description;
  final String? requiredTicketType;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? venue;
  final String? externalUrl;
  final bool? isInPerson;
}
