// ignore_for_file: unused_field

import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/car_info_cubit.dart';
import 'package:core_cubit/cubit/car_info_state.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/car_info_repository.dart';

import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:core_utils/formatters/vehicle_formatters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class CarInfoScreen extends StatelessWidget {
  final void Function(String carNumber, String series, String number)? onCheckFine;

  const CarInfoScreen({super.key, this.onCheckFine});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CarInfoCubit(context.read<CarInfoRepository>()),
      child: _CarInfoView(onCheckFine: onCheckFine),
    );
  }
}

class _CarInfoView extends StatefulWidget {
  final void Function(String carNumber, String series, String number)? onCheckFine;
  const _CarInfoView({this.onCheckFine});

  @override
  State<_CarInfoView> createState() => _CarInfoViewState();
}

class _CarInfoViewState extends State<_CarInfoView> {
  late final TextEditingController _carNumberController;
  late final TextEditingController _techPassportController;

  String _carNumber = '';
  String _docSeries = '';
  String _docNumber = '';

  @override
  void initState() {
    super.initState();
    _carNumberController = TextEditingController();
    _techPassportController = TextEditingController();

    _loadSavedCarInfo();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      final carNumber = prefs.getString('carNumber');
      if (carNumber != null && carNumber.isNotEmpty) {
        debugPrint("🔄 FCM Token refreshed for $carNumber: $newToken");
        await FirebaseFirestore.instance.collection("cars").doc(carNumber).set({
          "fcmToken": newToken,
        }, SetOptions(merge: true));
      }
    });
  }

  @override
  void dispose() {
    _carNumberController.dispose();
    _techPassportController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCarInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final carNumber = prefs.getString('carNumber') ?? '';
    final techPassport = prefs.getString('techPassport') ?? '';

    _carNumberController.text = carNumber;
    _techPassportController.text = techPassport;

    if (carNumber.isNotEmpty) {
      _saveFcmToken(carNumber);
    }
  }

  Future<void> _saveFcmToken(String carNumber) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      debugPrint("🔑 Saving FCM Token for $carNumber: $token");
      await FirebaseFirestore.instance.collection("cars").doc(carNumber).set({
        "fcmToken": token,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _saveCarInfo(String carNumber, String techPassport) async {
    final parts = techPassport.split(' ');
    final series = parts.isNotEmpty ? parts[0] : '';
    final number = parts.length > 1 ? parts[1] : '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carNumber', carNumber);
    await prefs.setString('docSeries', series);
    await prefs.setString('docNumber', number);

    debugPrint("💾 Сохранил данные: $carNumber / $series / $number");

    setState(() {
      _carNumber = carNumber;
      _docSeries = series;
      _docNumber = number;
    });
  }
Future<String> getCaptchaToken() async {
   
    const token = '6LepNrErAAAAACkxJmNX--qVX9ImDpxwFKlxMtFf';
    debugPrint('✅ Используем токен: $token');
    return token;
  }


Future<void> _checkFines() async {
    final carNumber = _carNumberController.text.trim();
    final techPassport = _techPassportController.text.trim();

 
    if (carNumber.isEmpty || techPassport.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введіть номер авто та техпаспорт')));
      }
      return;
    }

    if (techPassport.length != 9) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Некорректний номер техпаспорта')));
      }
      return;
    }

    final series = techPassport.substring(0, 3).toUpperCase();
    final number = techPassport.substring(3);

    if (!RegExp(r'^[А-ЯІЇЄҐ]{3}$').hasMatch(series) || !RegExp(r'^\d{6}$').hasMatch(number)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Некорректний номер техпаспорта')));
      }
      return;
    }

   
    await _saveCarInfo(carNumber, techPassport);

    try {
   
      final captchaToken = await getCaptchaToken();

      debugPrint('📌 carNumber: $carNumber');
      debugPrint('📌 docSeries: $series');
      debugPrint('📌 docNumber: $number');
      debugPrint('📌 captchaToken: $captchaToken');

      final response = await http.post(
        Uri.parse("http://localhost:3000/api/fines"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "carNumber": carNumber,
          "docSeries": series,
          "docNumber": number,
          "captchaToken": captchaToken,
          "cookies": "cf_clearance=XXX; _gv_sessid=YYY",
        }),
      );

      if (response.statusCode == 200) {
        final finesHtml = response.body;
        debugPrint("📡 Ответ сервера: 200");
        debugPrint("✅ HTML штрафов: $finesHtml");
      } else {
        debugPrint("❌ Ошибка сервера: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Не удалось получить токен или штрафы: $e");
    }
  }






  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CarInfoCubit>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacers.verticalXLarge,
              Text(S.of(context).addition_cars, style: textTheme.title),
              AppSpacers.verticalHuge,
              Card(
                color: AppColors.neutreBlanc,
                shape: RoundedRectangleBorder(borderRadius: AppBorders.radius22),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).car_number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                      AppSpacers.verticalSmall,
                      TextField(
                        controller: _carNumberController,
                        onChanged: cubit.setCarNumber,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                        inputFormatters: [VehicleNumberFormatter(mapLatinToCyrillic: true)],
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.text,
                        maxLength: 8,
                        decoration: InputDecoration(
                          hintText: 'АН0000НА',
                          hintStyle: textTheme.hintText,
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                        ),
                      ),
                      AppSpacers.verticalLarge,
                      Text(S.of(context).reg_number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
                      AppSpacers.verticalSmall,
                      TextField(
                        controller: _techPassportController,
                        onChanged: cubit.setTechPassport,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
                        inputFormatters: [TechPassportFormatter()],
                        maxLength: 9,
                        decoration: InputDecoration(
                          hintText: 'ХЕE128436',
                          hintStyle: textTheme.hintText,
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.grey50,
                          border: OutlineInputBorder(borderRadius: AppBorders.radius18, borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacers.verticalLargeXL,
              BlocBuilder<CarInfoCubit, CarInfoState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: cubit.isFormValid
                          ? () async {
                              final error = cubit.validate();
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                                return;
                              }

                              await _saveCarInfo(_carNumberController.text, _techPassportController.text);

                              if (widget.onCheckFine != null) {
                                widget.onCheckFine!(
                                  _carNumberController.text,
                                  _techPassportController.text.substring(0, 3).toUpperCase(),
                                  _techPassportController.text.substring(3),
                                );
                              }
                              await _checkFines();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue700,
                        shape: RoundedRectangleBorder(borderRadius: AppBorders.radius16),
                      ),
                      child: Text(S.of(context).search, style: textTheme.buttonText),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
