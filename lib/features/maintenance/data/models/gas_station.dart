import 'package:json_annotation/json_annotation.dart';

part 'gas_station.g.dart';

@JsonSerializable()
class GasStation {
  final double lat;
  final double lng;
  final String name;
  final String vicinity;
  final double rating;

  const GasStation({
    required this.lat,
    required this.lng,
    required this.name,
    required this.vicinity,
    this.rating = 0,
  });

  GasStation copyWith({
    double? lat,
    double? lng,
    String? name,
    String? vicinity,
    double? rating,
  }) {
    return GasStation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      name: name ?? this.name,
      vicinity: vicinity ?? this.vicinity,
      rating: rating ?? this.rating,
    );
  }

  factory GasStation.fromJson(Map<String, dynamic> json) =>
      _$GasStationFromJson(json);

  Map<String, dynamic> toJson() => _$GasStationToJson(this);

  @override
  String toString() =>
      'GasStation(lat: $lat, lng: $lng, name: $name, vicinity: $vicinity, rating: $rating)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is GasStation &&
            other.lat == lat &&
            other.lng == lng &&
            other.name == name &&
            other.vicinity == vicinity &&
            other.rating == rating);
  }

  @override
  int get hashCode => Object.hash(lat, lng, name, vicinity, rating);
}
