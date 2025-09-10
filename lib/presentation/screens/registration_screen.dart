// ignore_for_file: unused_local_variable
import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_cubit/cubit/registration/registration_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/router/home_screen_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class RegistrationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const RegistrationScreen({super.key, this.onBack});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<RegistrationCubit>();
    final saved = cubit.loadCredentials();

    emailController = TextEditingController(text: saved['email']);
    passwordController = TextEditingController(text: saved['password']);

    emailController.addListener(() {
      cubit.saveCredentials(emailController.text, passwordController.text);
    });
    passwordController.addListener(() {
      cubit.saveCredentials(emailController.text, passwordController.text);
    });
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack ?? () {}),
      ),

      backgroundColor: AppColors.grey50,

      body: BlocBuilder<RegistrationCubit, bool>(
        builder: (context, isLoading) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacers.verticalXLarge,
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
                isLoading
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.only(left: 100),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await cubit.register(emailController.text, passwordController.text);

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(S.of(context).successfully_registration)));

                              final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                              homeState?.openPage(HomePage.addCar);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue700,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(S.of(context).registration, style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                AppSpacers.verticalMediumLarge,
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      await purchaseCubit.buySubscription(user.uid, 9.99);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(S.of(context).successfully_subscription)));
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
