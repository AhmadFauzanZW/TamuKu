import 'package:intl/intl.dart';

abstract final class Formatters {
  static final DateFormat dateFull = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  static final DateFormat dateShort = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat time = DateFormat('HH:mm', 'id_ID');
  static final DateFormat dateTime = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat dayAbbr = DateFormat('E', 'id_ID');

  static String formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    if (h > 0) return '${h}j ${m}m';
    return '${m}m';
  }

  static String formatPhone(String phone) {
    if (phone.startsWith('+62')) return phone;
    if (phone.startsWith('62')) return '+$phone';
    if (phone.startsWith('0')) return '+62${phone.substring(1)}';
    return phone;
  }
}
