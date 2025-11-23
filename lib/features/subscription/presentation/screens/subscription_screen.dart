import 'package:auto_route/auto_route.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/env/env.dart';
import 'package:flutter/material.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter_svg/svg.dart';
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
  int _selectedIndex = 0;
  final List<Map<String, String>> plans = [
    {"title": "7 днів", "price": "129,99 грн. в нед."},
    {"title": "1 місяць", "price": "429,99 грн. в мес."},
    {"title": "3 дні безплатно,далі", "price": "підписатися за 899,99 грн. в рік"},
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.grey50,
        elevation: 0,
        leading: BackButton(color: AppColors.blue700, onPressed: widget.onBack),
        title: Text("Спробуй Premium", style: textTheme.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 50, left: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                 _buildFeatureRow('assets/icons/no_ad.svg', "Без реклами", isSvg: true),
                  _buildFeatureRow(Icons.cloud_upload, "Збільшений ліміт завантаження"),
                  _buildFeatureRow(Icons.analytics, "Аналітіка"),
                  _buildFeatureRow(Icons.search, "Пошук штрафів"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                itemCount: plans.length + 1,
                itemBuilder: (context, index) {
                  final textTheme = Theme.of(context).textTheme;

                  if (index < plans.length) {
                    final plan = plans[index];
                    final isSelected = index == _selectedIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [AppColors.blue700, AppColors.blue700.withOpacity(0.4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                plan["title"]!,
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                plan["price"]!,
                                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Скасування у будь-який час у GooglePlay",
                            style: textTheme.hintAnalitText,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    launchUrl(Uri.parse(Env.termsUrl));
                                  },
                                  child: Text(
                                    "Умови використання",
                                    style: textTheme.black16bold.copyWith(color: AppColors.blue700),
                                    maxLines: 2,
                                    softWrap: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                            Flexible(
                                child: GestureDetector(
                                  onTap: _openPrivacy,
                                  child: Text(
                                    "Політика конфіденційності",
                                    style: textTheme.black16bold.copyWith(color: AppColors.blue700),
                                    maxLines: 2,
                                    softWrap: true,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildFeatureRow(dynamic iconOrPath, String text, {bool isSvg = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          isSvg
              ? SvgPicture.asset(
                  iconOrPath,
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(AppColors.blue700, BlendMode.srcIn),
                )
              : Icon(iconOrPath, color: AppColors.blue700),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
Future<void> _openPrivacy() async {
    final url = Uri.parse(Env.privacyPolicyUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

}
