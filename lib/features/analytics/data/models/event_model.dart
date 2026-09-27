import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime date;
  final String title;
  final double amount;
  final String mileage;
  final int iconCodePoint; 
  final int iconColorValue; 
  final ExpenseCategory category;

  @JsonKey(ignore: true) 
  final Widget? customIcon;

  EventModel({
    required this.date,
    required this.title,
    required this.amount,
    required this.mileage,
    required this.iconCodePoint,
    required this.iconColorValue,
    required this.category,
    this.customIcon,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);
  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  /// Every icon an event can carry, as constants: building IconData from a
  /// runtime code point would stop release builds from tree-shaking the
  /// MaterialIcons font ("Avoid non-constant invocations of IconData").
  static const _icons = <IconData>[
    Icons.local_gas_station,
    Icons.build,
    Icons.build_circle,
    Icons.local_car_wash,
    Icons.gpp_good,
    Icons.more_horiz,
  ];

  IconData get icon => _icons.firstWhere(
        (icon) => icon.codePoint == iconCodePoint,
        orElse: () => Icons.more_horiz,
      );
  Color get iconColor => Color(iconColorValue);

  
  static DateTime _dateFromJson(String date) => DateTime.parse(date);
  static String _dateToJson(DateTime date) => date.toIso8601String();
}
