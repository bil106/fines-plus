import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/features/reminders/data/models/reminder_item.dart';
import 'package:fines_plus/features/reminders/domain/planned_service.dart';
import 'package:flutter/material.dart';

/// Accent for a deadline that needs attention: amber when it's close, red
/// once it has passed, nothing otherwise.
extension ReminderStatusTint on ReminderStatus {
  Color? get attentionTint => switch (this) {
    ReminderStatus.overdue => AppColors.lightRed,
    ReminderStatus.soon => AppColors.amber,
    ReminderStatus.upcoming || ReminderStatus.done => null,
  };
}

/// Same accent for a planned service: amber until its day passes, then red.
extension PlannedStatusTint on PlannedStatus {
  Color? get tint => switch (this) {
    PlannedStatus.upcoming => AppColors.amber,
    PlannedStatus.overdue => AppColors.lightRed,
    PlannedStatus.none => null,
  };
}
