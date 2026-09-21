import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/analytics/presentation/widgets/history_tab.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:fines_plus/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:fines_plus/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:fines_plus/features/vehicle/presentation/cubit/car_cubit.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class AnalyticsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final String carNumber;
  final int initialTabIndex;

  const AnalyticsScreen({super.key, this.onBack, required this.carNumber, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return _AnalyticsScreenView(onBack: onBack, carNumber: carNumber, initialTabIndex: initialTabIndex);
  }
}

class _AnalyticsScreenView extends StatefulWidget {
  final VoidCallback? onBack;
  final String carNumber;
  final int initialTabIndex;
  const _AnalyticsScreenView({this.onBack, required this.carNumber, this.initialTabIndex = 0});

  @override
  State<_AnalyticsScreenView> createState() => AnalyticsScreenViewState();
}

class AnalyticsScreenViewState extends State<_AnalyticsScreenView> with SingleTickerProviderStateMixin {
  List<EventModel> events = [];
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    context.read<AnalyticsCubit>().updateDate(DateTime.now());
    _loadRecords();
  }

  @override
  void didUpdateWidget(covariant _AnalyticsScreenView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex && _tabController.index != widget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    events.clear();

    final settingsCubit = context.read<SettingsCubit>();
    final isMi = settingsCubit.state.unit == 'mil';

    String formatMileage(int mileage) {
      final value = isMi ? (mileage * 0.621371).toStringAsFixed(0) : mileage.toString();
      final unit = isMi ? 'mil' : 'km';
      return "$value $unit";
    }

    // Service
    final serviceJson = prefs.getString('service_records');
    if (serviceJson != null) {
      final List<dynamic> serviceList = jsonDecode(serviceJson);
      events.addAll(
        serviceList.map((e) {
          final record = ServiceRecord.fromJson(e);
          return EventModel(
            date: DateFormat('dd.MM.yyyy').parse(record.date),
            title: record.serviceName,
            amount: record.cost.toDouble(),
            mileage: formatMileage(record.mileage),
            iconCodePoint: Icons.build.codePoint,
            iconColorValue: AppColors.red.value,
            category: ExpenseCategory.service,
          );
        }),
      );
    }

    // Fuel
    final fuelJson = prefs.getString('fuel_records');
    if (fuelJson != null) {
      final List<dynamic> fuelList = jsonDecode(fuelJson);
      events.addAll(
        fuelList.map((e) {
          final record = FuelRecord.fromJson(e);
          return EventModel(
            date: record.date,
            title: "${record.fuelType} / ${record.volume} ${S.of(context).l}",
            amount: record.cost.toDouble(),
            mileage: formatMileage(record.mileage),
            iconCodePoint: Icons.local_gas_station.codePoint,
            iconColorValue: AppColors.green.value,
            category: ExpenseCategory.fuel,
          );
        }),
      );
    }

    // Tuning
    final tuningJson = prefs.getString('tuning_records');
    if (tuningJson != null) {
      final List<dynamic> tuningList = jsonDecode(tuningJson);
      events.addAll(
        tuningList.map((e) {
          final record = TuningRecord.fromJson(e);
          return EventModel(
            date: record.date,
            title: record.tuningName,
            amount: record.cost.toDouble(),
            mileage: formatMileage(record.mileage),
            iconCodePoint: Icons.build_circle.codePoint,
            iconColorValue: AppColors.blue700.value,
            category: ExpenseCategory.tuning,
            customIcon: Image.asset('assets/icons/tuning.jpg', height: 24, width: 24),
          );
        }),
      );
    }

    // Car Wash
    final carWashJson = prefs.getString('car_wash_records');
    if (carWashJson != null) {
      final List<dynamic> carWashList = jsonDecode(carWashJson);
      events.addAll(
        carWashList.map((e) {
          final record = CarWashRecord.fromJson(e);
          return EventModel(
            date: record.date,
            title: S.of(context).car_wash,
            amount: record.amount.toDouble(),
            mileage: formatMileage(record.mileage),
            iconCodePoint: Icons.local_car_wash.codePoint,
            iconColorValue: AppColors.energyBlue.value,
            category: ExpenseCategory.other,
          );
        }),
      );
    }

    events.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) setState(() {});

    final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
    homeState?.exportHistory = events;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.energyBlue50,
        appBar: AppBar(
          backgroundColor: AppColors.energyBlue50,
          leading: AppBackButton(onPressed: widget.onBack),
        ),
        body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(S.of(context).analitics, style: textTheme.title, maxLines: 2, softWrap: true),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                          homeState?.openPage(HomePage.export);
                        },
                        icon: const Icon(Icons.upload, size: 18),
                        label: Text(S.of(context).export),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue700),
                      ),
                    ],
                  ),

                  TabBar(
                    indicatorColor: AppColors.blue700,
                    labelColor: AppColors.blue700,
                    unselectedLabelColor: AppColors.neutreGrey,

                    controller: _tabController,
                    tabs: [
                      Tab(text: S.of(context).statistics),
                      Tab(text: S.of(context).history),
                      Tab(text: S.of(context).schedule),
                    ],
                  ),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          const StatisticsScreen(),
                          HistoryTab(events: events),
                          ScheduleScreen(
                            repository: context.read<ScheduleRepository>(),
                            reminderRepository: context.read<ReminderRepository>(),
                            pushHelper: context.read<PushHelper>(),
                            carNumber: context.read<CarCubit>().state.carId,
                            ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Map<String, List<EventModel>> groupEventsByMonth(List<EventModel> events) {
  events.sort((a, b) => b.date.compareTo(a.date));

  Map<String, List<EventModel>> grouped = {};

  for (var event in events) {
    final key = "${event.date.year}-${event.date.month.toString().padLeft(2, '0')}";

    if (!grouped.containsKey(key)) {
      grouped[key] = [];
    }
    grouped[key]!.add(event);
  }

  return grouped;
}
