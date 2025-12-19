import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/core/helpers/push_helper.dart';
import 'package:fines_plus/features/analytics/data/models/event_model.dart';
import 'package:fines_plus/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:fines_plus/features/export/presentation/screens/export_screen.dart';

import 'package:fines_plus/features/fines/presentation/screens/fines_screeen.dart';
import 'package:fines_plus/features/history/presentation/screens/history_screen.dart';
import 'package:fines_plus/features/home/presentation/screens/home_screen.dart';
import 'package:fines_plus/features/reminders/data/repository/reminder_repository.dart';
import 'package:fines_plus/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:fines_plus/features/schedule/data/repository/schedule_repository.dart';
import 'package:fines_plus/features/schedule/presentation/cubit/schedule_cubit.dart';
import 'package:fines_plus/features/vehicle/presentation/screens/car_info_screen.dart';
import 'package:fines_plus/presentation/screens/add_car_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_map_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/car_wash_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_map_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/fuel_up_screen.dart';
import 'package:fines_plus/features/registration/presentation/screens/registration_screen.dart';
import 'package:fines_plus/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/service_screen.dart';
import 'package:fines_plus/presentation/screens/onboarding_screen.dart';
import 'package:fines_plus/features/settings/presentation/screens/settings_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:fines_plus/features/maintenance/presentation/screens/tuning_screen.dart';
import 'package:fines_plus/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:fines_plus/presentation/screens/update_required_screen.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  final bool showOnboarding;

  AppRouter({this.showOnboarding = false, super.navigatorKey});

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRouteWrapper.page,
      path: '/',
      children: [
        AutoRoute(page: HomeRoute.page, path: 'home', initial: true),
        AutoRoute(page: AddCarRoute.page, path: 'add-car'),
        AutoRoute(page: FinesRoute.page, path: 'fines'),
        AutoRoute(page: RemindersRoute.page, path: 'reminders'),
        AutoRoute(page: MaintenanceRoute.page, path: 'maintenance'),
        AutoRoute(page: AnalyticsRoute.page, path: 'analytics'),
        AutoRoute(page: HistoryRoute.page, path: 'history'),
        AutoRoute(page: RegistrationRoute.page, path: 'registration'),
        AutoRoute(page: FuelUpRoute.page, path: 'fuel'),
        AutoRoute(page: ServiceRoute.page, path: 'service'),
        AutoRoute(page: ScheduleRoute.page, path: 'schedule'),
        AutoRoute(page: SubscriptionRoute.page, path: 'subscription'),
      ],
    ),

    
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding'),

    AutoRoute(page: CarInfoRoute.page, path: '/car-info'),
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
    AutoRoute(page: ExportRoute.page, path: '/export'),
    AutoRoute(page: FuelMapRoute.page, path: '/fuel-map'),
    AutoRoute(page: FuelUpRoute.page, path: '/fuel'),
    AutoRoute(page: TuningRoute.page, path: '/tuning'),
    AutoRoute(page: CarWashRoute.page, path: '/car_wash'),
    AutoRoute(page: CarWashMapRoute.page, path: '/car_wash_map'),
    AutoRoute(page: UpdateRequiredRoute.page, path: '/update'),
    AutoRoute(page: SubscriptionRoute.page, path: '/subscription'),
    AutoRoute(page: RegistrationRoute.page, path: '/registration'),
   

  
  ];
}
