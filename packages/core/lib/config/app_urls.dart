import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppUrls {
  static const String base = 'https://driver.top';
  static const String auth = '$base/auth/';
  static String editExp(int expId) => '$base/editexp/$expId';
  static const String exps = '$base/exps/';
  static String addExp(int expId) => '$base/addexp/$expId';


  // Google Places API
  static const String googlePlacesBase = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  static String nearbyGasStations(LatLng location, String apiKey, {int radius = 3000}) =>
      '$googlePlacesBase?location=${location.latitude},${location.longitude}&radius=$radius&type=gas_station&key=$apiKey';
  static const String nbuRateUSD = 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?valcode=USD&json';
}
