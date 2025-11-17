// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_event_ui_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LastEventUiModel _$LastEventUiModelFromJson(Map<String, dynamic> json) =>
    LastEventUiModel(
      title: json['title'] as String,
      date: json['date'] as String,
      description: json['description'] as String,
      amountValue: (json['amountValue'] as num).toDouble(),
      amount: json['amount'] as String,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$LastEventUiModelToJson(LastEventUiModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'date': instance.date,
      'description': instance.description,
      'amountValue': instance.amountValue,
      'amount': instance.amount,
      'category': instance.category,
    };
