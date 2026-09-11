import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_state.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
HomeScreenWrapperState? _wrapperState;
  bool _socialLoading = false;
  late final Future<void> _googleSignInInit;


  Timer? _emailCheckTimer;

  @override
  void initState() {
    super.initState();
    _googleSignInInit = _googleSignIn.initialize(
      serverClientId: '201100655892-ocbfb9gl3j1ad5ma9t6n6pove9dom2n4.apps.googleusercontent.com',
    );
    emailController = TextEditingController();
    passwordController = TextEditingController();

    final cubit = context.read<RegistrationCubit>();

    cubit.loadCredentials().then((data) {
      if (!mounted) return;
      emailController.text = data['email']!;
      passwordController.text = data['password']!;
      _validateForm();
      if (data['email']!.isNotEmpty) cubit.checkEmail(data['email']!);
    });

    emailController.addListener(() {
      final email = emailController.text.trim();
      _emailCheckTimer?.cancel();
      _emailCheckTimer = Timer(const Duration(milliseconds: 600), () {
        cubit.checkEmail(email);
        _validateForm();
      });
    });

    passwordController.addListener(_validateForm);
  }

  bool _isFormValid = false;

  void _validateForm() {
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();
    final isValid = email.isNotEmpty && email.contains('@') && pass.length >= 6;
    if (isValid != _isFormValid) setState(() => _isFormValid = isValid);
  }

Future<void> _onSubmit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cubit = context.read<RegistrationCubit>();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    await cubit.saveCredentials(email, password);
    await cubit.register(email, password);
    // Post-registration navigation (home vs subscription) is handled reactively
    // by the BlocConsumer listener below once `state.isRegistered` becomes true.
  }
Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() => _socialLoading = true);
    try {
      await _googleSignInInit;
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!context.mounted) return;
      await _onSocialLoginSuccess(context);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      debugPrint('Google sign-in error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${S.of(context).google_login_error}: ${e.description}')));
    } catch (e, s) {
      debugPrint('Google sign-in error: $e');
      debugPrint('$s');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${S.of(context).google_login_error}: $e')));
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }


  Future<void> _signInWithFacebook(BuildContext context) async {
    setState(() => _socialLoading = true);
    try {
      final result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).facebook_error)));
          return;
        }

        final credential = FacebookAuthProvider.credential(accessToken.tokenString);

        await FirebaseAuth.instance.signInWithCredential(credential);
        if (!context.mounted) return;
        await _onSocialLoginSuccess(context);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).facebook_login_successful)));
      } else if (result.status == LoginStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).facebook_login_cancelled)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${S.of(context).facebook_login_error}: ${result.message}')));
        debugPrint("${result.message}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${S.of(context).facebook_login_error}: $e')));
      debugPrint("error: $e");
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    setState(() => _socialLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: credential.identityToken, accessToken: credential.authorizationCode);

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      if (!context.mounted) return;
      await _onSocialLoginSuccess(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in with Apple successful'), backgroundColor: AppColors.blue700),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apple login error: $e')));
      debugPrint('Apple login error: $e');
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }

  Future<void> _onSocialLoginSuccess(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final usersRef = FirebaseFirestore.instance.collection("users").doc(user.uid);

    final doc = await usersRef.get();
    if (!doc.exists) {
      await usersRef.set({
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
        "isSubscribed": false,
        "subscriptionEndDate": null,
        "trialInfo": null,
      });
    }

    final hasSubscription = await context.read<RegistrationCubit>().checkSubscription();

    if (kDebugMode || hasSubscription) {
      context.router.replaceAll([HomeRouteWrapper(initialPage: HomePage.home)]);
    } else {
      context.router.replaceAll([SubscriptionRoute(debugMode: true)]);
    }
  }
@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _wrapperState ??= context.findAncestorStateOfType<HomeScreenWrapperState>();
  }
  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.energyBlue50,
      appBar: AppBar(
        backgroundColor: AppColors.energyBlue50,
        elevation: 0,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: BlocListener<SubscriptionCubit, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionBought) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.current.plan_activated)));
                Navigator.of(context).pop();
              } else if (state is SubscriptionError) {
                // ScaffoldMessenger.of(
                //   context,
                // ).showSnackBar(SnackBar(content: Text("${S.current.subscription_error}: ${state.message}")));
              }
            },
            child: Form(
              key: _formKey,
              child: BlocConsumer<RegistrationCubit, RegistrationState>(
                listener: (context, state) async {
                  if (state.isRegistered) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).successful_registration),
                        backgroundColor: AppColors.blue700,
                      ),
                    );

                    final regCubit = context.read<RegistrationCubit>();
                    final hasSubscription = await regCubit.checkSubscription();

                    if (kDebugMode || hasSubscription) {
                      context.router.replaceAll([HomeRouteWrapper()]);
                    } else {
                      context.router.replaceAll([
                        SubscriptionRoute(
                          debugMode: true,
                        onBack: () async {
                            await Future.delayed(const Duration(milliseconds: 150));

                            if (_wrapperState != null) {
                              _wrapperState!.openPage(HomePage.home);
                              return;
                            }

                            if (!mounted) return;
                            context.router.root.replaceAll([HomeRouteWrapper(initialPage: HomePage.subscription)]);
                          },

                        ),
                      ]);
                    }
                  }
                },

                builder: (context, state) {
                  final isLogin = state.isExistingUser;
                  final isLoading = state.isLoading;

                  return Column(
                    children: [
                      Text(
                        isLogin ? S.of(context).registration : S.of(context).sign_up,
                        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      AppSpacers.verticalXXXLarge,

                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          labelText: S.of(context).email,
                          errorText: state.emailError,
                          border: OutlineInputBorder(borderRadius: AppBorders.radiusLarge),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return S.of(context).enter_email;
                          if (!v.contains('@')) return S.of(context).incorrect_email;
                          return null;
                        },
                      ),
                      AppSpacers.verticalLarge,

                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: S.of(context).password,
                          errorText: state.error,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return S.of(context).enter_password;
                          if (v.length < 6) return S.of(context).min_char;
                          return null;
                        },
                      ),
                      AppSpacers.verticalXXXLarge,

                      isLoading
                          ? const CircularProgressIndicator()
                          : InkWell(
                              onTap: _isFormValid ? () => _onSubmit(context) : null,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.colcm, AppColors.purpleRed],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    isLogin ? S.of(context).large_login : S.of(context).large_sign_up,
                                    style: textTheme.titleMedium?.copyWith(
                                      color: AppColors.neutreBlanc,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                      AppSpacers.verticalLargeXL,
                      TextButton(
                        onPressed: () => context.read<RegistrationCubit>().toggleLoginMode(),
                        child: Text(
                          isLogin ? S.of(context).dont_have_account : S.of(context).already_have_account,
                          style: const TextStyle(color: AppColors.purpleRed),
                        ),
                      ),

                      AppSpacers.verticalXXLarge,
                      Text(S.of(context).or_sign_in_using, style: const TextStyle(color: Colors.grey)),
                      AppSpacers.verticalMediumLarge,

                      _socialLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(),
                            )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Image.asset('assets/icons/google_logo.png', height: 30),
                            onPressed: () => _signInWithGoogle(context),
                          ),
                          AppSpacers.horizontalMedium,
                          IconButton(
                            icon: const Icon(Icons.facebook, color: AppColors.blue700, size: 30),
                            onPressed: () => _signInWithFacebook(context),
                          ),
                          AppSpacers.horizontalMedium,
                          IconButton(
                            icon: const Icon(Icons.apple, color: AppColors.black, size: 30),
                            onPressed: () => _signInWithApple(context),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
