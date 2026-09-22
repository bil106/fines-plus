import 'package:design_system/theme/app_brand_theme.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared AppBar for sub-pages reached via a back arrow (Налаштування,
/// Мій гараж, ...) - a round, outlined back button (visible against the
/// page's own light background, unlike a plain BackButton) and a larger,
/// consistently-styled title, so every such page looks the same.
class AppPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const AppPageAppBar(
      {super.key, required this.title, this.onBack, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.brandTheme.surfaceBg,
      elevation: 0,
      centerTitle: false,
      leadingWidth: 70,
      leading: AppBackButton(onPressed: onBack),
      title: Text(
        title,
        style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 20),
      ),
      actions: actions,
    );
  }
}
