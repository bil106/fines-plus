import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/config/app_config.dart';
import 'package:fines_plus/presentation/screens/add_car_screen.dart';
import 'package:fines_plus/presentation/screens/analytics_screen.dart';
import 'package:fines_plus/presentation/screens/car_info_screen.dart';
import 'package:fines_plus/presentation/screens/export_screen.dart';
import 'package:fines_plus/presentation/screens/fine_check_screen.dart';
import 'package:fines_plus/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/presentation/screens/history_screen.dart';
import 'package:fines_plus/presentation/screens/registration_screen.dart';
import 'package:fines_plus/presentation/screens/reminders_screen.dart';
import 'package:fines_plus/presentation/screens/settings_screen.dart';
import 'package:fines_plus/presentation/screens/support_screen.dart';
import 'package:fines_plus/presentation/screens/maintenance_screen.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
   
    AutoRoute(
      page: HomeRouteWrapper.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(page: AddCarRoute.page, path: 'add-car', initial: true),
        AutoRoute(page: FinesRoute.page, path: 'fines'),
        AutoRoute(page: RemindersRoute.page, path: 'reminders'),
        AutoRoute(page: MaintenanceRoute.page, path: 'maintenance'),
        AutoRoute(page: AnalyticsRoute.page, path: 'analytics'),
        AutoRoute(page: HistoryRoute.page, path: 'history'),
        AutoRoute(page: RegistrationRoute.page, path: 'registration'),
         AutoRoute(page: FuelUpRoute.page, path: 'fuel'),
      ],
    ),

   
    AutoRoute(page: CarInfoRoute.page, path: '/car-info'),
    AutoRoute(page: SupportRoute.page, path: '/support'),
    AutoRoute(page: FineCheckRoute.page, path: '/fine_check'),
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: HistoryRoute.page, path: '/history'),
    AutoRoute(page: MaintenanceRoute.page, path: '/maintenance'),
    AutoRoute(page: AnalyticsRoute.page, path: '/analytics'),
    AutoRoute(page: ExportRoute.page, path: '/export'),
    AutoRoute(page: RegistrationRoute.page, path: '/registration'),
    AutoRoute(page: FuelUpRoute.page, path: '/fuel'),
  ];
}
