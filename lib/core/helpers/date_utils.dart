import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String getShortMonthLabel(DateTime date, BuildContext context) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final formatter = DateFormat.MMM(locale);
  String month = formatter.format(date); 

  
  month = month[0].toUpperCase() + month.substring(1);

  final year = date.year;
  return "$month $year";
}

/// "25 Sep" / "25 вер" (or "25 Sep 2026" with [withYear]) in [locale] - the
/// app's language, not a hardcoded month list. intl's Ukrainian short months
/// end in a dot ("вер."), dropped to match the app's compact dates.
String formatShortDate(DateTime date, String locale, {bool withYear = false}) =>
    DateFormat(withYear ? 'd MMM y' : 'd MMM', locale).format(date).replaceAll('.', '');
