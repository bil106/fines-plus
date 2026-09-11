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
