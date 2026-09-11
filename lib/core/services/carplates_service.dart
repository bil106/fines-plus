import 'dart:convert';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:http/http.dart' as http;

class CarPlatesService {
  static const _baseUrl = 'https://api.carplates.app/ua/gov-registration';
  static const _apiKey = 'DEMOdemoDEMOdemoDEMOdemoDEMOdemo';

  Future<CarInfoModel> fetchCarInfo(String number) async {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {'X-Locale': 'uk', 'X-API-Key': _apiKey, 'Content-Type': 'application/json'},
          body: jsonEncode({'number': number}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return CarInfoModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception(json['error'] ?? S.current.request_error);
      }
    } else {
      throw Exception('${S.current.connection_error} (${response.statusCode})');
    }
  }
}

