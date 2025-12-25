import 'package:auto_route/auto_route.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router/app_router.dart';

@RoutePage()
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      final firstLaunch = prefs.getBool('first_launch') ?? true;
      final user = FirebaseAuth.instance.currentUser;

      bool hasSubscription = false;

      if (user != null) {
        hasSubscription = await context.read<RegistrationCubit>().checkSubscription();
      }

      if (!context.mounted) return;

      if (firstLaunch) {
        await prefs.setBool('first_launch', false);
        context.router.replaceAll([const OnboardingRoute()]);
      } else if (!hasSubscription) {
        context.router.replaceAll([HomeRouteWrapper(initialPage: HomePage.subscription)]);
      } else {
        context.router.replaceAll([HomeRouteWrapper(initialPage: HomePage.home)]);
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
