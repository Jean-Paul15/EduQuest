class LiveClassItem {
  const LiveClassItem({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.zoomLink,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;
  final String zoomLink;
}
