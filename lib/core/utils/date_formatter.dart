import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);
  static String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);
  static String formatDateTime(DateTime date) => DateFormat('MMM dd, yyyy hh:mm a').format(date);
  static String todayLabel() => 'Today is ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}';
}
