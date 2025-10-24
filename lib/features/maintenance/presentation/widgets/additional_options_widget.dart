// ignore_for_file: unused_field, unused_local_variable

import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_cubit.dart';
import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AdditionalOptionsWidget extends StatefulWidget {
  final AdditionalOptionsCubit cubit;
  const AdditionalOptionsWidget({super.key, required this.cubit});

  @override
  State<AdditionalOptionsWidget> createState() => _AdditionalOptionsWidgetState();
}

class _AdditionalOptionsWidgetState extends State<AdditionalOptionsWidget> {
  InAppWebViewController? _webController;
  bool showOptions = false;
  bool _showWebViewForLogin = false;

  @override
  void initState() {
    super.initState();
    widget.cubit.checkSavedTokens();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AdditionalOptionsCubit, AdditionalOptionsState>(
      bloc: widget.cubit,
      builder: (context, state) {
        String? status;
        bool isExtracting = false;

        if (state is AdditionalOptionsLoading) isExtracting = true;
        if (state is AdditionalOptionsTokensPresent) status = 'Tokens already present';
        if (state is AdditionalOptionsTokensMissing) status = 'No tokens yet';
        if (state is AdditionalOptionsExtracted) status = 'Tokens extracted';
        if (state is AdditionalOptionsError) status = state.message;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => showOptions = !showOptions),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).additional_options, style: textTheme.titleMedium),
                  Icon(showOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: Text(S.of(context).open_site),
                    onPressed: () => setState(() => _showWebViewForLogin = true),
                  ),
                  if (status != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(status, style: textTheme.bodyMedium?.copyWith(color: AppColors.green)),
                    ),
                  if (_showWebViewForLogin)
                    SizedBox(
                      height: 1200,
                      child: Column(
                        children: [
                          Expanded(
                            child: InAppWebView(
                              initialUrlRequest: URLRequest(url: WebUri(Env.edriveUrl)),
                              onWebViewCreated: (controller) => _webController = controller,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              crossFadeState: showOptions ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        );
      },
    );
  }
}
