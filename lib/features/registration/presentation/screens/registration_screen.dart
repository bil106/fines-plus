import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/config/flavor_config.dart';
import 'package:fines_plus/core/theme/theme_config.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_cubit.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_state.dart';
import 'package:fines_plus/features/registration/presentation/screens/garage_setup_screen.dart';
import 'package:fines_plus/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

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
  static Future<void>? _googleSignInInit;

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
    });
  }

  bool _isNewAccountAwaitingSubscription = false;
  bool _isNewAccountAwaitingGarageSetup = false;

  bool _bypassPaywall(bool hasSubscription) =>
      kDebugMode ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      hasSubscription;

  /// Subscription check + navigation into the app, for the "existing user
  /// logs in" path only. New accounts go through [_startPostAuthFlow]
  /// instead so Передплата/Мій гараж show in the right order.
  Future<void> _continueToApp(BuildContext context) async {
    final regCubit = context.read<RegistrationCubit>();
    final hasSubscription = await regCubit.checkSubscription();
    if (!context.mounted) return;

    if (_bypassPaywall(hasSubscription)) {
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
            context.router.root.replaceAll([
              HomeRouteWrapper(initialPage: HomePage.subscription),
            ]);
          },
        ),
      ]);
    }
  }

  /// New-account onboarding order: Реєстрація -> Передплата (unless
  /// bypassed) -> Мій гараж -> Home. Передплата is shown in-place (like
  /// Мій гараж already was) rather than via router navigation, so its back
  /// button can return here without losing this onboarding sequence.
  Future<void> _startPostAuthFlow(
    BuildContext context, {
    required bool isNewAccount,
  }) async {
    if (!isNewAccount) {
      await _continueToApp(context);
      return;
    }

    final regCubit = context.read<RegistrationCubit>();
    final hasSubscription = await regCubit.checkSubscription();
    if (!mounted) return;

    if (_bypassPaywall(hasSubscription)) {
      setState(() => _isNewAccountAwaitingGarageSetup = true);
    } else {
      setState(() => _isNewAccountAwaitingSubscription = true);
    }
  }

  void _finishNewAccountOnboarding(BuildContext context) {
    context.router.replaceAll([HomeRouteWrapper()]);
  }

  Future<void> _onSubmit(BuildContext context) async {
    if (_socialLoading || context.read<RegistrationCubit>().state.isLoading) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cubit = context.read<RegistrationCubit>();
    final email = emailController.text.trim();
    final password = passwordController.text;

    await cubit.register(email, password);
    if (cubit.state.isRegistered) await cubit.saveCredentials(email, password);
    // Post-registration navigation (home vs subscription) is handled reactively
    // by the BlocConsumer listener below once `state.isRegistered` becomes true.
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    if (_socialLoading || context.read<RegistrationCubit>().state.isLoading) {
      return;
    }
    setState(() => _socialLoading = true);
    try {
      await (_googleSignInInit ??= _googleSignIn.initialize(
        // Android reads the web client ID from the flavor's own
        // google-services.json (default_web_client_id) when this is null.
        // iOS has no such fallback, so Fines+'s project ID is still passed
        // there - only for the finesplus flavor, same as main.dart's
        // FirebaseOptions, until other flavors get their own iOS target.
        serverClientId:
            defaultTargetPlatform == TargetPlatform.iOS && currentFlavor == 'finesplus'
                ? '201100655892-ocbfb9gl3j1ad5ma9t6n6pove9dom2n4.apps.googleusercontent.com'
                : null,
      ));
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw FirebaseAuthException(code: 'missing-google-id-token');
      }
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!context.mounted) return;
      await _onSocialLoginSuccess(context);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      debugPrint('Google sign-in error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context).google_login_error}: ${e.description}',
          ),
        ),
      );
    } catch (e, s) {
      debugPrint('Google sign-in error: $e');
      debugPrint('$s');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).google_login_error}: $e')),
      );
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    if (_socialLoading || context.read<RegistrationCubit>().state.isLoading) {
      return;
    }
    setState(() => _socialLoading = true);
    try {
      final random = Random.secure();
      final rawNonce = base64Url.encode(
        List<int>.generate(32, (_) => random.nextInt(256)),
      );
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
      if (!context.mounted) return;

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(S.of(context).facebook_error)));
          return;
        }

        final credential = accessToken is LimitedToken
            ? OAuthProvider(
                'facebook.com',
              ).credential(idToken: accessToken.tokenString, rawNonce: rawNonce)
            : FacebookAuthProvider.credential(accessToken.tokenString);

        await FirebaseAuth.instance.signInWithCredential(credential);
        if (!context.mounted) return;
        await _onSocialLoginSuccess(context);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).facebook_login_successful)),
        );
      } else if (result.status == LoginStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).facebook_login_cancelled)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context).facebook_login_error}: ${result.message}',
            ),
          ),
        );
        debugPrint("${result.message}");
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).facebook_login_error}: $e')),
      );
      debugPrint("error: $e");
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    if (_socialLoading || context.read<RegistrationCubit>().state.isLoading) {
      return;
    }
    setState(() => _socialLoading = true);
    try {
      await FirebaseAuth.instance.signInWithProvider(
        AppleAuthProvider()
          ..addScope('email')
          ..addScope('name'),
      );
      if (!context.mounted) return;
      await _onSocialLoginSuccess(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).apple_login_successful),
          backgroundColor: AppColors.blue700,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-cancelled') return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).apple_login_error(e.message ?? e.code))));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).apple_login_error(e.toString()))));
      debugPrint('Apple login error: $e');
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }

  Future<void> _onSocialLoginSuccess(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final usersRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid);

    final doc = await usersRef.get();
    final isNewAccount = !doc.exists;
    if (isNewAccount) {
      await usersRef.set({
        "email": user.email,
        "createdAt": FieldValue.serverTimestamp(),
        "isSubscribed": false,
        "subscriptionEndDate": null,
        "trialInfo": null,
      });
    }

    if (!mounted) return;

    await _startPostAuthFlow(context, isNewAccount: isNewAccount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _wrapperState ??= context.findAncestorStateOfType<HomeScreenWrapperState>();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNewAccountAwaitingSubscription) {
      return SubscriptionScreen(
        onBack: () => setState(() {
          _isNewAccountAwaitingSubscription = false;
          _isNewAccountAwaitingGarageSetup = true;
        }),
        onPurchaseSuccess: () => setState(() {
          _isNewAccountAwaitingSubscription = false;
          _isNewAccountAwaitingGarageSetup = true;
        }),
      );
    }
    if (_isNewAccountAwaitingGarageSetup) {
      return GarageSetupScreen(
        onDone: () => _finishNewAccountOnboarding(context),
      );
    }

    final background = context.brandTheme.surfaceBg;
    final border = context.brandTheme.surfaceBorder;
    // The mockup's {{accent}} is the raw brand hex, not Material3's
    // tonal-palette colorScheme.primary derived from it (which can land on
    // a noticeably duller tone for some seed colors) - same source
    // hero_expense_card.dart uses for its own accent.
    final blue = ThemeConfig.hexToColor(context.watch<AppConfig>().primaryColorHex);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: AppBackButton(onPressed: widget.onBack),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Form(
                key: _formKey,
                child: BlocConsumer<RegistrationCubit, RegistrationState>(
                  listenWhen: (previous, current) =>
                      !previous.isRegistered && current.isRegistered,
                  listener: (context, state) async {
                    await _startPostAuthFlow(
                      context,
                      isNewAccount: !state.isExistingUser,
                    );
                  },
                  builder: (context, state) {
                    final busy = state.isLoading || _socialLoading;
                    final isLogin = state.isExistingUser;
                    // Flat label-card look matching every other form in the
                    // app (AppFieldCard/DatePickerCard) - label always
                    // visible above the value, not Material's floating
                    // OutlineInputBorder label.
                    InputDecoration decoration(
                      String hint,
                      String? error,
                    ) => InputDecoration(
                      hintText: hint,
                      error: error == null ? null : Text(error, softWrap: true),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      hintStyle: const TextStyle(
                        color: AppColors.catOther,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                    Widget field({
                      required String label,
                      required Widget child,
                    }) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.neutreBlanc,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          child,
                        ],
                      ),
                    );
                    return AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isLogin
                                ? S.of(context).login
                                : S.of(context).registration,
                            textAlign: TextAlign.center,
                            style: context.brandTheme.displayTextStyle.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 18),
                          field(
                            label: S.of(context).email,
                            child: TextFormField(
                              controller: emailController,
                              enabled: !busy,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                              decoration: decoration('you@email.com', state.emailError),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              autocorrect: false,
                              errorBuilder: (context, error) =>
                                  Text(error, softWrap: true),
                              validator: (value) {
                                final email = value?.trim() ?? '';
                                if (email.isEmpty) {
                                  return S.of(context).enter_email;
                                }
                                if (!email.contains('@')) {
                                  return S.of(context).incorrect_email;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          field(
                            label: S.of(context).password,
                            child: TextFormField(
                              controller: passwordController,
                              enabled: !busy,
                              obscureText: true,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: 2),
                              autofillHints: [
                                isLogin
                                    ? AutofillHints.password
                                    : AutofillHints.newPassword,
                              ],
                              decoration: decoration('• • • • • • • •', state.error),
                              onFieldSubmitted: (_) => _onSubmit(context),
                              errorBuilder: (context, error) =>
                                  Text(error, softWrap: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S.of(context).enter_password;
                                }
                                if (value.length < 6) {
                                  return S.of(context).min_char;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 58,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: blue,
                                foregroundColor: AppColors.neutreBlanc,
                                disabledBackgroundColor: blue.withValues(
                                  alpha: 0.65,
                                ),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: busy ? null : () => _onSubmit(context),
                              child: busy
                                  ? const SizedBox.square(
                                      dimension: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.neutreBlanc,
                                      ),
                                    )
                                  : Text(
                                      isLogin
                                          ? S.of(context).large_login
                                          : S.of(context).large_sign_up,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => context
                                      .read<RegistrationCubit>()
                                      .toggleLoginMode(),
                            child: Text(
                              isLogin
                                  ? S.of(context).dont_have_account
                                  : S.of(context).already_have_account,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blue,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(child: Divider(color: border)),
                              Flexible(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    S.of(context).or_sign_in_using,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: border)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButton(
                                'Google',
                                Image.asset(
                                  'assets/icons/google_logo.png',
                                  height: 22,
                                ),
                                busy ? null : () => _signInWithGoogle(context),
                              ),
                              if (context
                                  .watch<AppConfig>()
                                  .facebookLoginEnabled) ...[
                                const SizedBox(width: 18),
                                _socialButton(
                                  'Facebook',
                                  const Icon(
                                    Icons.facebook,
                                    color: AppColors.facebookBlue,
                                    size: 25,
                                  ),
                                  busy
                                      ? null
                                      : () => _signInWithFacebook(context),
                                ),
                              ],
                              if (defaultTargetPlatform ==
                                  TargetPlatform.iOS) ...[
                                const SizedBox(width: 18),
                                _socialButton(
                                  'Apple',
                                  const Icon(
                                    Icons.apple,
                                    color: AppColors.ink,
                                    size: 25,
                                  ),
                                  busy ? null : () => _signInWithApple(context),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String label, Widget icon, VoidCallback? onPressed) {
    return SizedBox.square(
      dimension: 48,
      child: IconButton(
        tooltip: label,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.neutreBlanc,
          shape: CircleBorder(side: BorderSide(color: context.brandTheme.surfaceBorder)),
        ),
        icon: icon,
      ),
    );
  }
}
