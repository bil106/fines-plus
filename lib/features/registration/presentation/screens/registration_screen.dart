import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_state.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:fines_plus/router/app_router.dart';
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
  Timer? _emailCheckTimer;

  @override
  void initState() {
    super.initState();
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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Потрібна авторизація")));
      return;
    }

  
    try {
      await context.read<SubscriptionCubit>().finishPurchase(user.uid);

      final subState = context.read<SubscriptionCubit>().state;
      if (subState is SubscriptionBought) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("План успішно активований ✅")));
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Не вдалося активувати підписку: $e")));
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
      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar( SnackBar(content: Text(S.of(context).google_login), backgroundColor: AppColors.blue700));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${S.of(context).google_login_error}: $e'), backgroundColor: AppColors.blue700));
       debugPrint("${S.of(context).google_login_error}: $e");
    }
  }
Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Facebook Error: AccessToken is empty')));
          return;
        }

        final credential = FacebookAuthProvider.credential(accessToken.tokenString);

        await FirebaseAuth.instance.signInWithCredential(credential);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facebook login successful')));
      } else if (result.status == LoginStatus.cancelled) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Facebook login has been cancelled by the user.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Facebook login error: ${result.message}')));
       debugPrint("${result.message}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Facebook login error: $e')));
       debugPrint("error: $e");
    }
  }





  Future<void> _signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: credential.identityToken, accessToken: credential.authorizationCode);

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in with Apple successful'), backgroundColor: AppColors.blue700));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apple login error: $e')));
      debugPrint('Apple login error: $e');
    }
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
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        elevation: 0,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: BlocListener<SubscriptionCubit, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionBought) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("План успішно активований ✅")));
                Navigator.of(context).pop();
              } else if (state is SubscriptionError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Помилка підписки: ${state.message}")));
              }
            },
            child: Form(
              key: _formKey,
              child: BlocConsumer<RegistrationCubit, RegistrationState>(
                listener: (context, state) {
                  if (state.error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: AppColors.blue700));
                  }
                  if (state.isRegistered) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).successful_registration),
                        backgroundColor: AppColors.blue700,
                      ),
                    );
                    context.router.replace(SubscriptionRoute());
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

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: S.of(context).password,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return S.of(context).enter_password;
                          if (v.length < 6) return S.of(context).min_char;
                          return null;
                        },
                      ),
                      AppSpacers.verticalXXXLarge,

                      // Button
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Image.asset('assets/icons/google_logo.png', height: 30),
                            onPressed: _signInWithGoogle,
                          ),
                          AppSpacers.horizontalMedium,
                          IconButton(
                            icon: const Icon(Icons.facebook, color: AppColors.blue700, size: 30),
                            onPressed: () => _signInWithFacebook(context),
                          ),
                          AppSpacers.horizontalMedium,
                          IconButton(
                            icon: const Icon(Icons.apple, color: AppColors.black, size: 30),
                            onPressed: () => _signInWithApple(),
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
