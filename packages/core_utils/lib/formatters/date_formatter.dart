import 'package:intl/intl.dart';

/// Class for formatting dates in the application.
/// All methods are static – they can be called without creating an instance.
class DateFormatter {
/// Formats the date as `dd.MM.yyyy`
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
/// Formats the date and time as `dd.MM.yyyy HH:mm`
  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

 /// Example: "October 29, 2025"
  static String formatLongDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'ru').format(date);
  }
}
