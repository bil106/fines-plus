// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gas_station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GasStation _$GasStationFromJson(Map<String, dynamic> json) => GasStation(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  name: json['name'] as String,
  vicinity: json['vicinity'] as String,
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$GasStationToJson(GasStation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'name': instance.name,
      'vicinity': instance.vicinity,
      'rating': instance.rating,
    };
