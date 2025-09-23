import 'package:core_data/src/models/expense_category.dart';
import 'package:flutter/material.dart';

class EventModel {
  final String date;
  final String title;
  final double amount;
  final String mileage;
  final IconData icon;
  final Color iconColor;
  final ExpenseCategory category;
  final Widget? customIcon;

  EventModel({
    required this.date,
    required this.title,
    required this.amount,
    required this.mileage,
    required this.icon,
    required this.iconColor,
    required this.category,
    this.customIcon,
  });
}
