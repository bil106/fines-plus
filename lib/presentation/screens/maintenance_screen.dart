// ignore_for_file: unused_element_parameter

import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/maintenance/maintenance_state.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/fuel_record_card.dart';
import 'package:fines_plus/core/widgets/service_record_card.dart';
import 'package:fines_plus/presentation/screens/service_screen.dart';
import 'package:fines_plus/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_cubit/cubit/maintenance/maintenance_cubit.dart';

@RoutePage()
class MaintenanceScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onFuelUp;
  final VoidCallback? onService;
  final VoidCallback? onCalendar;
  final VoidCallback? onSettings;

  const MaintenanceScreen({super.key, this.onBack, this.onCalendar, this.onSettings, this.onFuelUp, this.onService});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaintenanceCubit(),
      child: _MaintenanceScreenView(
        onBack: widget.onBack,
        onCalendar: widget.onCalendar,
        onSettings: widget.onSettings,
      ),
    );
  }
}

class _MaintenanceScreenView extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCalendar;
  final VoidCallback? onSettings;
  final VoidCallback? onFuelUp;
  final VoidCallback? onServic;
  const _MaintenanceScreenView({this.onBack, this.onCalendar, this.onSettings, this.onFuelUp, this.onServic});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: onBack ?? () {}),
      ),
      body: BlocBuilder<MaintenanceCubit, MaintenanceState>(
        builder: (context, state) {
          final cubit = context.read<MaintenanceCubit>();

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.of(context).tech_service, style: textTheme.title),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: [
                          ...state.serviceRecords.map((r) => ServiceRecordCard(record: r)),
                          ...state.fuelRecords.map((r) => FuelRecordCard(record: r)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AdBannerWidget(),
                  ],
                ),
              ),

              if (state.isMenuOpen)
                GestureDetector(
                  onTap: cubit.closeMenu,
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),

              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildAnimatedAction(context, Icons.local_gas_station, S.of(context).fuel_up, () async {
                      final record = await context.router.push<FuelRecord>(FuelUpRoute());
                      if (record != null) {
                        cubit.addFuelRecord(record);
                        onFuelUp?.call();
                      }
                    }, state.isMenuOpen),

                    _buildAnimatedAction(context, Icons.build, S.of(context).service, () async {
                      final records = await Navigator.push<List<ServiceRecord>>(
                        context,
                        MaterialPageRoute(builder: (_) => const ServiceScreen()),
                      );
                      if (records != null && records.isNotEmpty) {
                        cubit.addServiceRecords(records);
                      }
                    }, state.isMenuOpen),

                    _buildAnimatedAction(
                      context,
                      Icons.calendar_today,
                      S.of(context).calendar,
                      onCalendar,
                      state.isMenuOpen,
                    ),

                    _buildAnimatedAction(context, Icons.settings, S.of(context).settings, onSettings, state.isMenuOpen),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: cubit.toggleMenu,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        child: AnimatedRotation(
                          turns: state.isMenuOpen ? 0.125 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(state.isMenuOpen ? Icons.close : Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, String tooltip, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }

  Widget _buildAnimatedAction(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback? onTap,
    bool isVisible,
  ) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: isVisible ? 1 : 0,
        child: _buildAction(context, icon, tooltip, onTap),
      ),
    );
  }
}
