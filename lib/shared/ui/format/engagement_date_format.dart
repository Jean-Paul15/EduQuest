import 'package:intl/intl.dart';

String formatEngagementDate(DateTime d) =>
    DateFormat("d MMM yyyy 'à' HH'h'mm", 'fr_FR').format(d.toLocal());
