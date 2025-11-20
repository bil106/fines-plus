import 'package:json_annotation/json_annotation.dart';

part 'maintenance_task.g.dart';





@JsonSerializable(explicitToJson: true)
class MaintenanceTask {
  final String title;
  final DateTime? lastServiceDate;
  final int lastMileage;
  final int? actualMileage;
  final int? intervalKm;
  final Duration? intervalTime;
  final String? comment;

  MaintenanceTask({
    required this.title,
    this.lastServiceDate,
    required this.lastMileage,
    this.actualMileage,
    this.intervalKm,
    this.intervalTime,
    this.comment,
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) => _$MaintenanceTaskFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceTaskToJson(this);

  MaintenanceTask copyWith({
    String? title,
    DateTime? lastServiceDate,
    int? lastMileage,
    int? actualMileage,
    int? intervalKm,
    Duration? intervalTime,
    String? comment,
  }) {
    return MaintenanceTask(
      title: title ?? this.title,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastMileage: lastMileage ?? this.lastMileage,
      actualMileage: actualMileage ?? this.actualMileage,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalTime: intervalTime ?? this.intervalTime,
      comment: comment ?? this.comment,
    );
  }


  double getProgress() {
    if (intervalKm != null && actualMileage != null) {
      final kmPassed = actualMileage! - lastMileage;
      return (kmPassed / intervalKm!).clamp(0.0, 1.0);
    }

    if (intervalTime != null && lastServiceDate != null) {
      final daysPassed = DateTime.now().difference(lastServiceDate!).inDays;
      return (daysPassed / intervalTime!.inDays).clamp(0.0, 1.0);
    }

    return 0.0;
  }
}
