import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/analytics/presentation/widgets/history_tab.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/analytics/data/repository/analytics_repository.dart';
import 'package:fines_plus/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:fines_plus/features/expenses/data/models/car_wash_record.dart';
import 'package:fines_plus/features/expenses/data/models/expense_category.dart';
import 'package:fines_plus/features/expenses/data/models/fuel_record.dart';
import 'package:fines_plus/features/expenses/data/models/service_record.dart';
import 'package:fines_plus/features/expenses/data/models/tuning_record.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:fines_plus/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class AnalyticsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final String carNumber;

  const AnalyticsScreen({super.key, this.onBack, required this.carNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsCubit(repository: AnalyticsRepository(firestore: FirebaseFirestore.instance)),
      child: _AnalyticsScreenView(onBack: onBack),
    );
  }
}

class _AnalyticsScreenView extends StatefulWidget {
  final VoidCallback? onBack;

  const _AnalyticsScreenView({this.onBack});

  @override
  State<_AnalyticsScreenView> createState() => _AnalyticsScreenViewState();
}

class _AnalyticsScreenViewState extends State<_AnalyticsScreenView> {
  List<EventModel> events = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();

   
    final serviceJson = prefs.getString('service_records');
    if (serviceJson != null) {
      final List<dynamic> serviceList = jsonDecode(serviceJson);
      events.addAll(
        serviceList.map((e) {
          final record = ServiceRecord.fromJson(e);
          return EventModel(
            date: record.date,
            title: record.serviceName,
            amount: record.cost.toDouble(),
            mileage: "${record.mileage} ${S.of(context).km}",
            icon: Icons.build,
            iconColor: AppColors.red,
            category: ExpenseCategory.service,
          );
        }),
      );
    }

  
    final fuelJson = prefs.getString('fuel_records');
    if (fuelJson != null) {
      final List<dynamic> fuelList = jsonDecode(fuelJson);
      events.addAll(
        fuelList.map((e) {
          final record = FuelRecord.fromJson(e);
          return EventModel(
            date: record.date,
            title: "${record.fuelType} / ${record.volume} л.",
            amount: record.cost.toDouble(),
            mileage: "${record.mileage} ${S.of(context).km}",
            icon: Icons.local_gas_station,
            iconColor: AppColors.green,
            category: ExpenseCategory.fuel,
          );
        }),
      );
    }

 
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
            mileage: "${record.mileage} ${S.of(context).km}",
            icon: Icons.build_circle, 
            iconColor: AppColors.blue700,
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
            amount: record.cost.toDouble(),
            mileage: "${record.mileage} ${S.of(context).km}",
            icon: Icons.local_car_wash,
            iconColor: AppColors.energyBlue,
            category: ExpenseCategory.other,
          );
        }),
      );
    }


    
    events.sort((a, b) => DateFormat('dd.MM.yyyy').parse(b.date).compareTo(DateFormat('dd.MM.yyyy').parse(a.date)));

    setState(() {});

   
    final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
    homeState?.exportHistory = events;
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.grey50,
        appBar: AppBar(
          backgroundColor: AppColors.grey50,
          leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () {}),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(S.of(context).analitics, style: textTheme.title),
                  AppSpacers.horizontalXXMassive,
                  ElevatedButton.icon(
                    onPressed: () {
                      final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                      if (homeState != null) {
                        homeState.openPage(HomePage.export);
                      }
                    },
                    label: Text(S.of(context).export, style: textTheme.white18W400),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
                      textStyle: textTheme.black16bold,
                    ),
                  ),
                ],
              ),

            

              TabBar(
                indicatorColor: AppColors.blue700,
                labelColor: AppColors.blue700,
                unselectedLabelColor: AppColors.neutreGrey,
                tabs: [
                  Tab(text: S.of(context).statistics),
                  Tab(text: S.of(context).history),
                  Tab(text: S.of(context).schedule),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    const StatisticsScreen(),
                    HistoryTab(events: events),
                    ScheduleScreen(
                      repository: context.read<ScheduleRepository>(),
                      reminderRepository: context.read<ReminderRepository>(),
                      pushHelper: context.read<PushHelper>(),
                      carNumber: S.of(context).car_number,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<EventModel>> groupEventsByMonth(List<EventModel> events) {
    events.sort((a, b) => b.date.compareTo(a.date));

    Map<String, List<EventModel>> grouped = {};

    for (var event in events) {
      final key = event.date;

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(event);
    }

    return grouped;
  }
}
