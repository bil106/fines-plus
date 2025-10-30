import 'package:json_annotation/json_annotation.dart';
import 'package:core_utils/formatters/date_formatter.dart';

class DateFormatterConverter implements JsonConverter<DateTime, String> {
  const DateFormatterConverter();

  @override
  DateTime fromJson(String json) {
    try {
     
      final parts = json.split('.');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  String toJson(DateTime object) {
    return DateFormatter.formatDate(object);
  }
}
