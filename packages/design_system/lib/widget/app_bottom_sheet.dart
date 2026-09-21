import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';

/// Shared scaffold for the app's draggable "quick add" bottom sheets
/// (fuel/service/insurance/etc.): drag handle, title row with a close X,
/// a scrollable body, and a Save button pinned outside the scrollable
/// area so long forms don't push it off screen.
class AppBottomSheet extends StatelessWidget {
  final String title;
  final WidgetBuilder contentBuilder;
  final String saveLabel;
  final VoidCallback onSave;
  final WidgetBuilder? footerBuilder;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.contentBuilder,
    required this.saveLabel,
    required this.onSave,
    this.footerBuilder,
  });

  /// Opens this scaffold as a modal bottom sheet and returns whatever
  /// [onSave] causes the sheet to be popped with.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required WidgetBuilder contentBuilder,
    required String saveLabel,
    required VoidCallback onSave,
    WidgetBuilder? footerBuilder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AppBottomSheet(
        title: title,
        contentBuilder: contentBuilder,
        saveLabel: saveLabel,
        onSave: onSave,
        footerBuilder: footerBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: context.brandTheme.surfaceBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutreGreyLight,
                      borderRadius: AppBorders.radiusSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black87,
                                  )),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: contentBuilder(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (footerBuilder != null) footerBuilder!(context),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onSave,
                            child: Text(saveLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
