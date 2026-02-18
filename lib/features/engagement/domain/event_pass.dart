class EventPass {
  const EventPass({
    required this.passCode,
    required this.createdAt,
    this.attendanceFee,
    this.status,
  });

  final String passCode;
  final DateTime createdAt;
  final double? attendanceFee;
  final String? status;
}
