// ignore_for_file: unused_field

import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';

import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/fuel_record_card.dart';
import 'package:fines_plus/core/widgets/service_record_card.dart';
import 'package:fines_plus/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/presentation/screens/service_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



@RoutePage()
class MaintenanceScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onFuelUp;
  final VoidCallback? onService;
  final VoidCallback? onCalendar;
  final VoidCallback? onSettings;

  const MaintenanceScreen({super.key, this.onBack, this.onFuelUp, this.onService, this.onCalendar, this.onSettings});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  List<ServiceRecord> _records = [];
List<FuelRecord> _fuelRecords = [];
@override
  void initState() {
    super.initState();
    _loadRecords();
    _loadFuelRecords(); 
  }

 Future<void> _saveFuelRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _fuelRecords.map((r) => r.toJson()).toList();
    await prefs.setString('fuel_records', jsonEncode(jsonList));
  }
Future<void> _loadFuelRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('fuel_records');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _fuelRecords = jsonList.map((e) => FuelRecord.fromJson(e)).toList();
      });
    }
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('service_records');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _records = jsonList.map((e) => ServiceRecord.fromJson(e)).toList();
      });
    }
  }

  // Сохранение записей в SharedPreferences
  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _records.map((r) => r.toJson()).toList();
    await prefs.setString('service_records', jsonEncode(jsonList));
  }

  // Добавление записи и её сохранение
  void addRecord(ServiceRecord record) {
    setState(() {
      _records.add(record);
    });
    _saveRecords();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () {}),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Тех. Обслуговування", style: textTheme.title),
                const SizedBox(height: 12),
              Expanded(
                  child: ListView(
                    children: [
                      ..._records.map((r) => ServiceRecordCard(record: r)),
                      ..._fuelRecords.map((r) => FuelRecordCard(record: r)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const AdBannerWidget(),
              ],
            ),
          ),

          if (_isMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _isMenuOpen = false),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),

          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildAnimatedAction(Icons.local_gas_station, "Заправка", 1, onTap: ()async{

                  final record = await Navigator.push<FuelRecord>(
                      context,
                      MaterialPageRoute(builder: (_) => const FuelUpScreen()),
                    );

                    if (record != null) {
                      setState(() {
                        _fuelRecords.add(record); 
                      });
                      _saveFuelRecords(); 
                    }

                }),
                _buildAnimatedAction(
                  Icons.build,
                  "Сервіс",
                  2,
                  onTap: () async {
                    final records = await Navigator.push<List<ServiceRecord>>(
                      context,
                      MaterialPageRoute(builder: (_) => const ServiceScreen()),
                    );

                    if (records != null && records.isNotEmpty) {
                      setState(() {
                        _records.addAll(records);
                      });
                      _saveRecords();
                    }

                  },
                ),
                _buildAnimatedAction(Icons.calendar_today, "Календар", 3, onTap: widget.onCalendar),
                _buildAnimatedAction(Icons.settings, "Налаштування", 4, onTap: widget.onSettings),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => _isMenuOpen = !_isMenuOpen),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: AnimatedRotation(
                      turns: _isMenuOpen ? 0.125 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(_isMenuOpen ? Icons.close : Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAction(IconData icon, String tooltip, int order, {VoidCallback? onTap}) {
    final delay = order * 50;

    return AnimatedSlide(
      duration: Duration(milliseconds: 200 + delay),
      offset: _isMenuOpen ? Offset.zero : const Offset(0, 1),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200 + delay),
        opacity: _isMenuOpen ? 1 : 0,
        child: GestureDetector(
          onTap:
              onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Натиснута кнопка: $tooltip")));
              },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Icon(icon, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}
