import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

class IsoDateConverter implements JsonConverter<DateTime, String> {
  const IsoDateConverter();

  @override
  DateTime fromJson(String json) {
    try {
      return DateTime.parse(json);
    } catch (_) {
      try {
        return DateFormat('dd.MM.yyyy').parse(json); 
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  @override
  String toJson(DateTime object) {
    return DateFormat("yyyy-MM-dd").format(object);
  }
}
