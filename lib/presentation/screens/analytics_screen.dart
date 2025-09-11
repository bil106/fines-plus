import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/analytics/analytics_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:core_repository/analytics_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';

import 'package:fines_plus/core/widgets/history_tab.dart';

import 'package:fines_plus/core/widgets/schedule_tab.dart';

import 'package:fines_plus/presentation/screens/statistics_screen.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            iconColor: Colors.red,
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
            iconColor: Colors.green,
            category: ExpenseCategory.fuel,
          );
        }),
      );
    }

    events.sort((a, b) => b.date.compareTo(a.date));

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
                  AppSpacers.horizontalXXHuge,
                  ElevatedButton.icon(
                    onPressed: () {
                      final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                      if (homeState != null) {
                        homeState.openPage(HomePage.export);
                      }
                    },
                    label: Text(S.of(context).export, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue700,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              AppSpacers.verticalMedium,

              TabBar(
                indicatorColor: AppColors.blue700,
                labelColor: AppColors.blue700,
                unselectedLabelColor: Colors.grey,
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
                    const ScheduleTab(),
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
