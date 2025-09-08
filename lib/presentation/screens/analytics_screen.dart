import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/analytics_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:core_repository/analytics_repository.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/action_card.dart';
import 'package:fines_plus/core/widgets/ad_banner_widget.dart';
import 'package:fines_plus/core/widgets/maintenance_card.dart';
import 'package:fines_plus/core/widgets/time_line_item.dart';
import 'package:fines_plus/presentation/screens/statistics_screen.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  final events = [
    EventModel(
      date: DateTime(2025, 8, 24),
      title: "АИ-95 + / 35 L.",
      subtitle: "Gas station: Нет в списке",
      amount: "2 170 UAH",
      mileage: "164201 km",
      icon: Icons.local_gas_station,
      iconColor: Colors.green,
    ),
    EventModel(
      date: DateTime(2025, 8, 2),
      title: "Services",
      subtitle: "",
      amount: "3 342 UAH",
      mileage: "163275 km",
      icon: Icons.build,
      iconColor: Colors.red,
    ),
    EventModel(
      date: DateTime(2025, 7, 28),
      title: "АИ-95 / 35 L.",
      subtitle: "Gas station: Нет в списке",
      amount: "2 135 UAH",
      mileage: "162952 km",
      icon: Icons.local_gas_station,
      iconColor: Colors.green,
    ),
  ];
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
                  Text("Аналітика", style: textTheme.title),
                  AppSpacers.horizontalXXHuge,
                  ElevatedButton.icon(
                    onPressed: () {
                      final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                      homeState?.openPage(HomePage.export);
                    },
                    label: const Text("Експорт", style: TextStyle(color: Colors.white)),
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

              /// TabBar
              TabBar(
                indicatorColor: AppColors.blue700,
                labelColor: AppColors.blue700,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Statistics"),
                  Tab(text: "History"),
                  Tab(text: "Schedule"),
                ],
              ),

             
              Expanded(
                child: TabBarView(
                  children: [
                  
                  const StatisticsScreen(),
                   

                   
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupEventsByMonth(events).entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        entry.key, 
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Divider(color: Colors.grey), 
                                    ],
                                  ),
                                ),
                              ),

                            
                              ...entry.value.map(
                                (event) => TimelineItem(
                                  icon: event.icon,
                                  iconColor: event.iconColor,
                                  date: DateFormat("dd.MM.yyyy").format(event.date),
                                  title: event.title,
                                  subtitle: event.subtitle,
                                  amount: event.amount,
                                  mileage: event.mileage,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),


                    /// Schedule
                     SingleChildScrollView(
                      child: Column(
                        children: [
                          MaintenanceCard(
                            title: "Замена масла двигателя",
                            progress: 0.8,
                            priorKm: 5604,
                            priorDays: 116,
                            periodicityKm: 7000,
                          ),
                          Column(
                            children: [
                              ActionCard(
                                title: "Шины зимние",
                                icon: Icons.tire_repair,
                                progress: 0.0,
                                priorExecution: "-",
                                periodicity: "-",
                                isWarning: true,
                              ),
                              ActionCard(
                                title: "Замена масла АКПП",
                                icon: Icons.settings,
                                progress: 0.1,
                                priorExecution: "5335 km\n111 day",
                                periodicity: "50000 km",
                                isWarning: true,
                              ),
                              ActionCard(
                                title: "Диагностика подвески",
                                icon: Icons.medical_services,
                                progress: 0.14,
                                priorExecution: "26 days",
                                periodicity: "6 months",
                                isWarning: true,
                              ),
                            ],
                          ),
                          AppSpacers.verticalHuge,
                          const AdBannerWidget(),
                        ],
                      ),
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

    final formatter = DateFormat("MMMM yyyy", "en_US"); 
    Map<String, List<EventModel>> grouped = {};

    for (var event in events) {
      final key = formatter.format(event.date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(event);
    }

    return grouped;
  }

}
