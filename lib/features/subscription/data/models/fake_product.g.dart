// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fake_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FakeProduct _$FakeProductFromJson(Map<String, dynamic> json) => FakeProduct(
  id: json['id'] as String,
  title: json['title'] as String,
  price: json['price'] as String,
  months: (json['months'] as num).toInt(),
);

Map<String, dynamic> _$FakeProductToJson(FakeProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'months': instance.months,
    };
