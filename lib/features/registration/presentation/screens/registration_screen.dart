// ignore_for_file: unused_local_variable
import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_state.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

@RoutePage()
class RegistrationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RegistrationScreen({super.key, this.onBack});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isLoadingCredentials = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    isLoadingCredentials = false;
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.blue700,
            content: Text('${S.current.successful_registration}: ${user.email}'),
          ),
        );

        final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
        homeState?.openPage(HomePage.addCar);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.blue700, content: Text("${S.current.google_login_error}: $e")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseCubit = context.read<PurchaseCubit>();
    final cubit = context.read<RegistrationCubit>();
    final textTheme = Theme.of(context).textTheme;

    if (isLoadingCredentials) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () {}),
      ),
      backgroundColor: AppColors.grey50,
      body: BlocBuilder<RegistrationCubit, RegistrationState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacers.verticalMediumLarge,
                Text(S.of(context).registration, style: textTheme.title),
                AppSpacers.verticalHuge,

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: S.of(context).email),
                ),
                AppSpacers.verticalMediumLarge,
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: S.of(context).password),
                  obscureText: true,
                ),
                AppSpacers.verticalXXXLarge,

                state.isLoading
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.only(left: 100),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await cubit.register(emailController.text, passwordController.text);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.blue700,
                                  content: Text(S.of(context).successfully_registration),
                                ),
                              );

                              final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                              homeState?.openPage(HomePage.addCar);
                            } catch (e) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(backgroundColor: AppColors.blue700, content: Text("Error: $e")));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue700,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
                          ),
                          child: Text(S.of(context).registration, style: textTheme.white18W400),
                        ),
                      ),

                AppSpacers.verticalMediumLarge,

                // Google Sign-In button
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: ElevatedButton.icon(
                    icon: Image.asset('assets/icons/google_logo.png', height: 20),
                    label: Text(S.of(context).sign_in_google),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutreBlanc,
                      foregroundColor: AppColors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
                    ),
                    onPressed: () => _signInWithGoogle(),
                  ),
                ),

                // Subscription button
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      await purchaseCubit.buySubscription(user.uid, 9.99);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.blue700,
                          content: Text(S.of(context).successfully_subscription),
                        ),
                      );
                    },
                    child: Text(S.of(context).buy_subscription),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
