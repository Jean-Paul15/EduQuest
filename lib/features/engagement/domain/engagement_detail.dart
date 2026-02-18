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
    this.meetingUrl,
    this.logoUrl,
    this.isInPerson,
    this.locationLat,
    this.locationLng,
    this.pricingMode,
    this.feeFull,
    this.feeHalf,
    this.feeFree,
    this.feeCampaignFree,
    this.freeForFull,
    this.requireWhatsapp,
  });

  final String id;
  final String title;
  final String description;
  final String? requiredTicketType;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? venue;
  final String? externalUrl;
  final String? meetingUrl;
  final String? logoUrl;
  final bool? isInPerson;
  final double? locationLat;
  final double? locationLng;
  final String? pricingMode;
  final double? feeFull;
  final double? feeHalf;
  final double? feeFree;
  final double? feeCampaignFree;
  final bool? freeForFull;
  final bool? requireWhatsapp;
}
