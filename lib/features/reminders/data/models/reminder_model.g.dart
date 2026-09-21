// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderModel _$ReminderModelFromJson(Map<String, dynamic> json) =>
    ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: ReminderModel._fromTimestamp(json['dateTime']),
      ownerId: json['ownerId'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPlannedService: json['isPlannedService'] as bool? ?? false,
      plannedCategory: json['plannedCategory'] as String?,
    );

Map<String, dynamic> _$ReminderModelToJson(ReminderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'dateTime': ReminderModel._toTimestamp(instance.dateTime),
      'isCompleted': instance.isCompleted,
      'ownerId': instance.ownerId,
      'isPlannedService': instance.isPlannedService,
      'plannedCategory': instance.plannedCategory,
    };
