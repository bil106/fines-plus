import 'package:core/config/app_urls.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/features/webview/data/datasource/mvs_fines_extractor.dart';
import 'package:fines_plus/features/webview/data/datasource/webview_form_injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Opens the official MVS fines service with the car's plate and document
/// pre-filled. The user solves the captcha and submits the form themselves;
/// once the results page loads, the fines are read off it and returned via
/// `Navigator.pop` as `List<Map<String, dynamic>>`.
class MvsFinesWebView extends StatelessWidget {
  final String plate;
  final String document;

  const MvsFinesWebView({super.key, required this.plate, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(S.of(context).fines_mvs_title),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                S.of(context).fines_mvs_hint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(AppUrls.mvsFines)),
                onLoadStop: (controller, url) => _onLoadStop(context, controller, url),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLoadStop(BuildContext context, InAppWebViewController controller, WebUri? url) async {
    final path = url?.path ?? '';
    if (!path.startsWith(MvsFinesExtractor.resultsPathPrefix)) {
      final fillJs = WebViewFormInjector.buildFillAndSubmitJs({'plate': plate, 'document': document});
      await controller.evaluateJavascript(source: fillJs);
      // The site's own scripts may still re-render the form right after load.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!context.mounted) return;
      await controller.evaluateJavascript(source: fillJs);
      return;
    }
    final raw = await controller.evaluateJavascript(source: MvsFinesExtractor.extractJs);
    final fines = MvsFinesExtractor.parse(raw);
    if (fines != null && context.mounted) Navigator.pop(context, fines);
  }
}
