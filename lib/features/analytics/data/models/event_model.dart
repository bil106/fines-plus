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

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get iconColor => Color(iconColorValue);

  
  static DateTime _dateFromJson(String date) => DateTime.parse(date);
  static String _dateToJson(DateTime date) => date.toIso8601String();
}
