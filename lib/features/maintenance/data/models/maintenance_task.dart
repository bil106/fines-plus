import 'package:json_annotation/json_annotation.dart';

part 'maintenance_task.g.dart';

@JsonSerializable(explicitToJson: true)
class MaintenanceTask {
  final String? id;
  final String description;
  final String category;
  final DateTime? lastServiceDate;
  final int lastMileage;
  final int? actualMileage;
  final int? intervalKm;
  final Duration? intervalTime;
  final String? comment;
  final bool isInsurance;

  MaintenanceTask({
    this.id,
    required this.description,
    required this.category,
    this.lastServiceDate,
    required this.lastMileage,
    this.actualMileage,
    this.intervalKm,
    this.intervalTime,
    this.comment,
    this.isInsurance = false,
  });

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) => _$MaintenanceTaskFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceTaskToJson(this);

  MaintenanceTask copyWith({
    String? id,
    String? description,
    String? category,
    DateTime? lastServiceDate,
    int? lastMileage,
    int? actualMileage,
    int? intervalKm,
    Duration? intervalTime,
    String? comment,
    bool? isInsurance,
  }) {
    return MaintenanceTask(
      id: id ?? this.id,
      description: description ?? this.description,
      category: category ?? this.category,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastMileage: lastMileage ?? this.lastMileage,
      actualMileage: actualMileage ?? this.actualMileage,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalTime: intervalTime ?? this.intervalTime,
      comment: comment ?? this.comment,
      isInsurance: isInsurance ?? this.isInsurance,
    );
  }

  double getProgress() {
    if (intervalTime != null && lastServiceDate != null) {
      final now = DateTime.now();
      final totalDays = intervalTime!.inDays;
      final passedDays = now.difference(lastServiceDate!).inDays;

      if (passedDays <= 0) return 0;
      if (passedDays >= totalDays) return 1;

      return passedDays / totalDays;
    }

    if (intervalKm != null && actualMileage != null) {
      final total = intervalKm!;
      final used = actualMileage! - lastMileage;
      if (used <= 0) return 0;
      if (used >= total) return 1;

      return used / total;
    }

    return 0;
  }
}
