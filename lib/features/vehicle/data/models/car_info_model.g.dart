// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarInfoModel _$CarInfoModelFromJson(Map<String, dynamic> json) => CarInfoModel(
  carNumber: json['carNumber'] as String,
  techPassport: json['techPassport'] as String,
  ownerId: json['ownerId'] as String,
);

Map<String, dynamic> _$CarInfoModelToJson(CarInfoModel instance) =>
    <String, dynamic>{
      'carNumber': instance.carNumber,
      'techPassport': instance.techPassport,
      'ownerId': instance.ownerId,
    };
