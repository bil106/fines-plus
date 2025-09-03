// ignore_for_file: unused_field

import 'package:auto_route/auto_route.dart';
import 'package:core_data/core_data.dart';
import 'package:design_system/colors/app_colors.dart';

import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/service_record_card.dart';
import 'package:flutter/material.dart';



@RoutePage()
class MaintenanceScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onFuelUp;
  final VoidCallback? onService;
  final VoidCallback? onCalendar;
  final VoidCallback? onSettings;

  const MaintenanceScreen({
    super.key,
    this.onBack,
    this.onFuelUp,
    this.onService,
    this.onCalendar,
    this.onSettings,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;

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
                Text("ТО", style: textTheme.titleLarge),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: mockServiceHistory.length,
                    itemBuilder: (context, index) {
                      return ServiceRecordCard(record: mockServiceHistory[index]);
                    },
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
            
             _buildAnimatedAction(Icons.local_gas_station, "Заправка", 1, onTap: widget.onFuelUp),
                _buildAnimatedAction(Icons.build, "Сервіс", 2, onTap: widget.onService),
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
