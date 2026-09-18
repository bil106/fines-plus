import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router/app_router.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveStartRoute();
    });
  }

  Future<void> _resolveStartRoute() async {
    if (_handled || !mounted) return;
    _handled = true;

    final prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getBool('first_launch') ?? true;
    final user = FirebaseAuth.instance.currentUser;

    bool hasSubscription = false;

    if (user != null && mounted) {
      hasSubscription = await context
          .read<RegistrationCubit>()
          .checkSubscription();
    }

    if (!mounted) return;

    final bypassSubscription =
        kDebugMode || Env.iosBypassSubscription || Platform.isIOS;

    if (firstLaunch) {
      await prefs.setBool('first_launch', false);
      context.router.replaceAll([const OnboardingRoute()]);
    } else if (user == null) {
      context.router.replaceAll([RegistrationRoute()]);
    } else if (bypassSubscription || hasSubscription) {
      context.router.replaceAll([HomeRouteWrapper(initialPage: HomePage.home)]);
    } else {
      context.router.replaceAll([
        HomeRouteWrapper(initialPage: HomePage.subscription),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
