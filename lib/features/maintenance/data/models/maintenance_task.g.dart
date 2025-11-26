// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaintenanceTask _$MaintenanceTaskFromJson(Map<String, dynamic> json) =>
    MaintenanceTask(
      description: json['description'] as String,
      category: json['category'] as String,
      lastServiceDate: json['lastServiceDate'] == null
          ? null
          : DateTime.parse(json['lastServiceDate'] as String),
      lastMileage: (json['lastMileage'] as num).toInt(),
      actualMileage: (json['actualMileage'] as num?)?.toInt(),
      intervalKm: (json['intervalKm'] as num?)?.toInt(),
      intervalTime: json['intervalTime'] == null
          ? null
          : Duration(microseconds: (json['intervalTime'] as num).toInt()),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$MaintenanceTaskToJson(MaintenanceTask instance) =>
    <String, dynamic>{
      'description': instance.description,
      'category': instance.category,
      'lastServiceDate': instance.lastServiceDate?.toIso8601String(),
      'lastMileage': instance.lastMileage,
      'actualMileage': instance.actualMileage,
      'intervalKm': instance.intervalKm,
      'intervalTime': instance.intervalTime?.inMicroseconds,
      'comment': instance.comment,
    };
