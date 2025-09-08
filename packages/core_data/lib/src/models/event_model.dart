import 'package:flutter/material.dart';

class EventModel {
  final DateTime date;
  final String title;
  final String subtitle;
  final String amount;
  final String mileage;
  final IconData icon;
  final Color iconColor;

  EventModel({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.mileage,
    required this.icon,
    required this.iconColor,
  });
}
