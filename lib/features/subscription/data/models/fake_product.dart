import 'package:json_annotation/json_annotation.dart';

part 'fake_product.g.dart';

@JsonSerializable()
class FakeProduct {
  final String id;
  final String title;
  final String price;
  final int months;

  FakeProduct({required this.id, required this.title, required this.price, required this.months});

  factory FakeProduct.fromJson(Map<String, dynamic> json) => _$FakeProductFromJson(json);

  Map<String, dynamic> toJson() => _$FakeProductToJson(this);
}
