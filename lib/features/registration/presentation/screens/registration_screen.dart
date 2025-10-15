// ignore_for_file: unused_local_variable
import 'package:auto_route/auto_route.dart';
import 'package:core_cubit/cubit/purchase/purchase_cubit.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isLoadingCredentials = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    isLoadingCredentials = false;

    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final isValid = email.isNotEmpty && email.contains('@') && pass.length >= 6;

    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
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
        homeState?.openPage(HomePage.subscription);
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
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacers.verticalMediumLarge,
                Text(S.of(context).registration, style: textTheme.titleLarge),
                AppSpacers.verticalHuge,

                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: S.of(context).email),
                        validator: (value) {
                          final v = (value ?? '').trim();
                          if (v.isEmpty) return S.of(context).field_required;
                          if (!v.contains('@')) return S.of(context).invalid_email;
                          return null;
                        },
                      ),
                      AppSpacers.verticalMediumLarge,
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: S.of(context).password),
                        obscureText: true,
                        validator: (value) {
                          final v = (value ?? '');
                          if (v.isEmpty) return S.of(context).field_required;
                          if (v.length < 6) return S.of(context).password_too_short;
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                AppSpacers.verticalXXXLarge,

                state.isLoading
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.only(left: 100),
                        child: ElevatedButton(
                          onPressed: (_isFormValid && !state.isLoading)
                              ? () async {
                                  if (!(_formKey.currentState?.validate() ?? false)) return;

                                  try {
                                    await cubit.register(emailController.text.trim(), passwordController.text.trim());

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.blue700,
                                        content: Text(S.of(context).successfully_registration),
                                      ),
                                    );

                                    final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                                    homeState?.openPage(HomePage.subscription);
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(backgroundColor: AppColors.blue700, content: Text("Error: $e")),
                                    );
                                  }
                                }
                              : null,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue700,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
                          ),
                          child: Text(
                            S.of(context).registration,
                            style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),

                AppSpacers.verticalMediumLarge,

                // === Google Sign-In ===
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
                    onPressed: _signInWithGoogle,
                  ),
                ),

                AppSpacers.verticalMediumLarge,

              
                Padding(
                  padding: const EdgeInsets.only(left: 100),
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      await purchaseCubit.buySubscription(user.uid, 9.99, 3);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.blue700,
                          content: Text(S.of(context).successfully_subscription),
                        ),
                      );

                      await Future.delayed(const Duration(milliseconds: 400));
                      if (context.mounted) {
                        final homeState = context.findAncestorStateOfType<HomeScreenWrapperState>();
                        homeState?.openPage(HomePage.subscription);
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue700,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: AppBorders.radiusLarge),
                    ),
                    child: Text(
                      S.of(context).buy_subscription,
                      style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
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
