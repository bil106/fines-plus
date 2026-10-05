import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/app/router/home_screen_wrapper.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/core/config/app_config.dart';
import 'package:fines_plus/core/theme/theme_config.dart';
import 'package:fines_plus/features/subscription/domain/entities/subscription.dart';
import 'package:fines_plus/app/router/app_router.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_cubit.dart';
import 'package:fines_plus/features/subscription/presentation/cubit/purchase/purchase_state.dart';
import 'package:fines_plus/features/subscription/presentation/widgets/paywall_feature_list.dart';
import 'package:fines_plus/features/subscription/presentation/widgets/paywall_hero.dart';
import 'package:fines_plus/features/subscription/presentation/widgets/paywall_plan_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SubscriptionScreen extends StatefulWidget {
  final bool debugMode;
  final VoidCallback? onBack;
  final VoidCallback? onPurchaseSuccess;
  const SubscriptionScreen({super.key, this.debugMode = true, this.onBack, this.onPurchaseSuccess});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late int _selectedIndex = plans.indexWhere((p) => p["popular"] == true).clamp(0, plans.length - 1);
  bool _navigated = false;
  bool _productsLoading = true;
  bool _productsUnavailable = false;
  final Map<String, ProductDetails> _productDetails = {};

  final List<Map<String, dynamic>> plans = [
    {
      "titleKey": "quarterly_plan",
      "productId": "sub_quarter",
      "price": 20.0,
      "periodKey": "period_3_months",
      "months": 3,
      "popular": false,
      "adFree": false,
      "hasTrial": true,
    },
    {
      "titleKey": "yearly_plan",
      "productId": "yearly_2549",
      "price": 50.0,
      "periodKey": "period_year",
      "months": 12,
      "popular": true,
      "adFree": true,
      "hasTrial": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    FirebaseCrashlytics.instance.setCustomKey('screen', 'SubscriptionScreen');
    _loadProductPrices();
  }

  Future<void> _loadProductPrices() async {
    setState(() {
      _productsLoading = true;
      _productsUnavailable = false;
    });
    try {
      final ids = plans.map((p) => p["productId"] as String).toSet();
      final response = await InAppPurchase.instance
          .queryProductDetails(ids)
          .timeout(const Duration(seconds: 15));
      if (response.error != null) {
        FirebaseCrashlytics.instance.log(
          'Product query failed: ${response.error}',
        );
      }
      if (response.notFoundIDs.isNotEmpty) {
        FirebaseCrashlytics.instance.log('Products not found: ${response.notFoundIDs}');
      }
      if (!mounted) return;
      setState(() {
        _productDetails.clear();
        for (final p in response.productDetails) {
          _productDetails[p.id] = p;
        }
        _productsLoading = false;
        _productsUnavailable = response.productDetails.isEmpty;
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'loadProductPrices failed');
      if (!mounted) return;
      setState(() {
        _productsLoading = false;
        _productsUnavailable = true;
      });
    }
  }

  String _localizedTitle(BuildContext context, String key) {
    final s = S.of(context);
    switch (key) {
      case 'quarterly_plan':
        return s.quarterly_plan;
      case 'yearly_plan':
        return s.yearly_plan;
      default:
        return key;
    }
  }

  String _localizedPeriod(BuildContext context, String key) {
    final s = S.of(context);
    switch (key) {
      case 'period_3_months':
        return s.period_3_months;
      case 'period_year':
        return s.period_year;
      default:
        return key;
    }
  }

  String _trialDisclosureText(BuildContext context) {
    final plan = plans[_selectedIndex];
    final store = _productDetails[plan["productId"] as String];
    if (store == null) {
      return _productsLoading ? '' : S.of(context).store_unavailable;
    }
    final price = store.price;
    final period = _localizedPeriod(context, plan["periodKey"] as String);
    return S.of(context).trial_disclosure_detailed(price, period);
  }

  Future<void> _onPlanSelected(int index) async {
    setState(() => _selectedIndex = index);
  }

  String _trialLine(BuildContext context, Map<String, dynamic> plan) {
    final store = _productDetails[plan["productId"] as String];
    if (store == null) return '';
    final period = _localizedPeriod(context, plan["periodKey"] as String);
    return S.of(context).paywall_plan_trial_then(store.price, period);
  }

  /// Headline price of a card: the plan's price per week, in the store's
  /// currency, so the full amount doesn't scare off the user up front.
  String _weekPrice(Map<String, dynamic> plan) {
    final store = _productDetails[plan["productId"] as String];
    if (store == null) return _productsLoading ? "…" : "—";
    final weeks = (plan["months"] as int) * 52 / 12;
    return NumberFormat.simpleCurrency(name: store.currencyCode).format(store.rawPrice / weeks);
  }

  Future<void> _buySelectedPlan() async {
    FirebaseCrashlytics.instance.log('buySelectedPlan tapped, selectedIndex=$_selectedIndex');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      FirebaseCrashlytics.instance.log('user is null, redirecting to registration');
      context.router.push(RegistrationRoute());
      return;
    }

    final planData = plans[_selectedIndex];
    FirebaseCrashlytics.instance.log(
      'selected plan: '
      'productId=${planData["productId"]}, '
      'titleKey=${planData["titleKey"]}',
    );
    final plan = SubscriptionPlan(
      id: planData["productId"],
      title: planData["titleKey"],
      price: planData["price"],
      months: planData["months"],
      features: [],
    );
    FirebaseCrashlytics.instance.log('calling PurchaseCubit.buy');
    context.read<PurchaseCubit>().buy(plan);
  }

  void _handlePurchaseSuccess() {
    if (!mounted) {
      FirebaseCrashlytics.instance.log('PurchaseSuccess but widget not mounted');
      return;
    }

    FirebaseCrashlytics.instance.log('Handling purchase success navigation');

    if (widget.onPurchaseSuccess != null) {
      widget.onPurchaseSuccess!.call();
      return;
    }

    final wrapperState = context.findAncestorStateOfType<HomeScreenWrapperState>();

    if (wrapperState != null) {
      wrapperState.openPage(HomePage.garage);
      return;
    }

    context.router.replaceAll([HomeRouteWrapper(initialPage: HomePage.garage)]);
  }

  void _continueWithoutSubscription() {
    _handlePurchaseSuccess();
  }

  static const double _sheetOverlap = 24;

  /// Where the paywall is mandatory (store-billed Android release) back must
  /// not exist: it opens the app without a subscription. Debug and the iOS
  /// bypass keep it, matching how those builds skip the paywall elsewhere.
  bool get _canDismiss => kDebugMode || defaultTargetPlatform == TargetPlatform.iOS || Env.iosBypassSubscription;

  /// Hue (degrees) of the teal paywall artwork; other brands rotate from it.
  static const double _artworkHue = 175;

  /// "Save X%" for the popular plan, from the real store prices: its
  /// per-month rate against the priciest per-month rate among the others.
  String? _saveLabel(BuildContext context, Map<String, dynamic> plan) {
    if (plan["popular"] != true) return null;
    final store = _productDetails[plan["productId"] as String];
    if (store == null) return null;
    final perMonth = store.rawPrice / (plan["months"] as int);
    double? baseline;
    for (final other in plans) {
      final otherStore = _productDetails[other["productId"] as String];
      if (identical(other, plan) || otherStore == null) continue;
      final otherPerMonth = otherStore.rawPrice / (other["months"] as int);
      if (baseline == null || otherPerMonth > baseline) baseline = otherPerMonth;
    }
    if (baseline == null || baseline <= 0) return null;
    final percent = ((1 - perMonth / baseline) * 100).round();
    return percent > 0 ? S.of(context).paywall_save_percent(percent.toString()) : null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final config = context.watch<AppConfig>();
    // The mockup's {{accent}} is the raw brand hex, not Material3's
    // tonal-palette colorScheme.primary (see registration_screen.dart).
    final accent = ThemeConfig.hexToColor(config.primaryColorHex);
    final accentHsl = HSLColor.fromColor(accent);
    final dark = accentHsl.withLightness(0.2).toColor();
    final hueShift = accentHsl.hue - _artworkHue;
    final sheetRadius = BorderRadius.vertical(top: AppBorders.radius22.topLeft);

    return BlocListener<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseSuccess && !_navigated) {
          _navigated = true;
          FirebaseCrashlytics.instance.log('PurchaseSuccess received');
          _handlePurchaseSuccess();
        }

        if (state is PurchaseError) {
          FirebaseCrashlytics.instance.log('PurchaseError: ${state.message}');
          final display = state.message == 'store_unavailable'
              ? S.of(context).store_unavailable
              : S.of(context).subscription_error;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(display)));
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: context.brandTheme.surfaceBg,
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  PaywallHero(
                    dark: dark,
                    accent: accent,
                    hueShift: hueShift,
                    heroAsset: config.paywallHeroAsset,
                    brandName: config.brandName,
                    headline: S.of(context).paywall_headline(config.brandName),
                    subtitle: config.finesCheckEnabled
                        ? S.of(context).subscription_subtitle
                        : S.of(context).subscription_subtitle_no_fines,
                    sheetOverlap: _sheetOverlap,
                    leading: !_canDismiss
                        ? null
                        : widget.onBack != null
                        ? AppBackButton(onPressed: widget.onBack)
                        : (ModalRoute.of(context)?.canPop == true ? const AppBackButton() : null),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -_sheetOverlap),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      decoration: BoxDecoration(color: context.brandTheme.surfaceBg, borderRadius: sheetRadius),
                      child: Column(
                        children: [
                          PaywallFeatureList(accent: accent, hueShift: hueShift, showFines: config.finesCheckEnabled),
                          AppSpacers.verticalLarge,
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var index = plans.length - 1; index >= 0; index--) ...[
                                  if (index != plans.length - 1) AppSpacers.horizontalSmallMedium,
                                  Expanded(
                                    child: PaywallPlanCard(
                                      title: _localizedTitle(context, plans[index]["titleKey"] as String),
                                      weekPrice: _weekPrice(plans[index]),
                                      trialLine: _trialLine(context, plans[index]),
                                      isSelected: index == _selectedIndex,
                                      isPopular: plans[index]["popular"] == true,
                                      adFree: plans[index]["adFree"] == true,
                                      saveLabel: _saveLabel(context, plans[index]),
                                      accent: accent,
                                      onTap: () => _onPlanSelected(index),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (kDebugMode) ...[
                            AppSpacers.verticalLarge,
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _continueWithoutSubscription,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: accent),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                child: Text(
                                  'Continue without subscription',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: accent),
                                ),
                              ),
                            ),
                          ],

                          AppSpacers.verticalMedium,

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              _trialDisclosureText(context),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10.5, height: 1.4, color: AppColors.catOther),
                            ),
                          ),

                          AppSpacers.verticalMedium,

                          SizedBox(
                            width: double.infinity,
                            child: BlocBuilder<PurchaseCubit, PurchaseState>(
                              builder: (context, state) {
                                final loading = state is PurchaseInProgress;
                                final selectedProduct = _productDetails[plans[_selectedIndex]["productId"]];
                                final unavailable = _productsUnavailable || selectedProduct == null;
                                final disabled = loading || _productsLoading || unavailable;

                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: accent,
                                    foregroundColor: AppColors.neutreBlanc,
                                    disabledBackgroundColor: accent.withOpacity(0.5),
                                    shape: const StadiumBorder(),
                                  ),
                                  onPressed: disabled ? null : _buySelectedPlan,
                                  child: loading || _productsLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neutreBlanc),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              unavailable ? S.of(context).store_unavailable : S.of(context).get_plan,
                                              style: textTheme.black18bold.copyWith(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.neutreBlanc,
                                              ),
                                            ),
                                            if (!unavailable) ...[
                                              AppSpacers.horizontalSmall,
                                              const Icon(Icons.chevron_right, size: 20),
                                            ],
                                          ],
                                        ),
                                );
                              },
                            ),
                          ),

                          AppSpacers.verticalSmallMedium,
                          Text(
                            S.of(context).paywall_no_commitment,
                            textAlign: TextAlign.center,
                            style: textTheme.black13W400.copyWith(fontSize: 11.5, color: AppColors.textSecondary),
                          ),

                          if (!_productsLoading && _productDetails.length < plans.length)
                            TextButton(
                              onPressed: context.watch<PurchaseCubit>().state is PurchaseInProgress
                                  ? null
                                  : _loadProductPrices,
                              child: Text(S.of(context).service_retry),
                            ),

                          AppSpacers.verticalMedium,

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (config.moneyBackGuaranteeEnabled) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check, color: AppColors.textSecondary, size: 13),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        S.of(context).money_back,
                                        maxLines: 2,
                                        softWrap: true,
                                        style: textTheme.black14bold.copyWith(fontSize: 10.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                              ],
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lock, color: AppColors.textSecondary, size: 13),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      S.of(context).pay_safe,
                                      maxLines: 2,
                                      softWrap: true,
                                      style: textTheme.black14bold.copyWith(fontSize: 10.5, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          AppSpacers.verticalMedium,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  try {
                                    await launchUrl(
                                      Uri.parse(config.termsUrl ?? Env.termsUrl),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } catch (_) {}
                                },
                                child: Text(
                                  S.of(context).terms_of_use,
                                  style: textTheme.black16bold.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.catOther),
                                ),
                              ),
                              const SizedBox(width: 14),
                              GestureDetector(
                                onTap: _openPrivacy,
                                child: Text(
                                  S.of(context).privacy_policy,
                                  style: textTheme.black16bold.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.catOther),
                                ),
                              ),
                            ],
                          ),
                          AppSpacers.verticalMedium,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPrivacy() async {
    try {
      final config = context.read<AppConfig>();
      await launchUrl(
        Uri.parse(config.privacyPolicyUrl ?? Env.privacyPolicyUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }
}
