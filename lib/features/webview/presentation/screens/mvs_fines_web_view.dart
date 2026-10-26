import 'package:core/config/app_urls.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/widget/app_back_button.dart';
import 'package:fines_plus/features/webview/data/datasource/mvs_fines_extractor.dart';
import 'package:fines_plus/features/webview/data/datasource/webview_form_injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Opens the official MVS fines service with the car's plate and document
/// pre-filled. The user solves the captcha and submits the form themselves;
/// once the results page loads, the fines are read off it and returned via
/// `Navigator.pop` as `List<Map<String, dynamic>>`.
///
/// When the site itself can't be reached (it sits behind Cloudflare and
/// answers 5xx while its server is down), says so with a retry button
/// instead of leaving a blank page.
class MvsFinesWebView extends StatefulWidget {
  final String plate;
  final String document;

  const MvsFinesWebView({super.key, required this.plate, required this.document});

  @override
  State<MvsFinesWebView> createState() => _MvsFinesWebViewState();
}

class _MvsFinesWebViewState extends State<MvsFinesWebView> {
  bool _isLoading = true;
  bool _hasError = false;

  String get plate => widget.plate;
  String get document => widget.document;

  /// Dropping the error view builds a fresh webview, which loads the site again.
  void _retry() => setState(() {
    _hasError = false;
    _isLoading = true;
  });

  /// Only the page itself matters: a failing ad/analytics sub-request must
  /// not replace a working form with the error state.
  void _onMainFrameFailed() {
    if (mounted) setState(() => _hasError = true);
  }

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
            if (!_hasError)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  S.of(context).fines_mvs_hint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (_isLoading && !_hasError) const LinearProgressIndicator(),
            Expanded(
              child: _hasError ? _UnavailableView(onRetry: _retry) : InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(AppUrls.mvsFines)),
                onLoadStart: (controller, url) {
                  if (mounted) setState(() => _isLoading = true);
                },
                onReceivedError: (controller, request, error) {
                  if (request.isForMainFrame ?? true) {
                    _onMainFrameFailed();
                  }
                },
                onReceivedHttpError: (controller, request, response) {
                  if ((request.isForMainFrame ?? true) && (response.statusCode ?? 0) >= 500) {
                    _onMainFrameFailed();
                  }
                },
                onLoadStop: (controller, url) => _onLoadStop(context, controller, url),
                // The results page isn't always reached via a full page load -
                // on some WebView builds the site swaps the results in via
                // history.pushState/replaceState instead, which fires this
                // callback but never onLoadStop.
                onUpdateVisitedHistory: (controller, url, isReload) => _tryExtract(context, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLoadStop(BuildContext context, InAppWebViewController controller, WebUri? url) async {
    if (mounted) setState(() => _isLoading = false);
    // The error page has no form to fill and no results to read.
    if (_hasError) return;
    final path = url?.path ?? '';
    debugPrint('MvsFinesWebView: onLoadStop path=$path');
    if (path.startsWith(MvsFinesExtractor.resultsPathPrefix)) {
      await _tryExtract(context, controller);
      return;
    }

    final fillJs = WebViewFormInjector.buildFillAndSubmitJs({'plate': plate, 'document': document});
    await controller.evaluateJavascript(source: fillJs);
    // The site's own scripts may still re-render the form right after load.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!context.mounted) return;
    await controller.evaluateJavascript(source: fillJs);
    // Some WebView builds land on the results without the URL path ever
    // matching resultsPathPrefix - try reading them regardless, instead of
    // assuming the form was actually re-rendered.
    await _tryExtract(context, controller);
  }

  /// Reads fines off whatever the webview currently shows and pops with them
  /// if it's the results page; a no-op otherwise - extractJs itself checks
  /// for `.search-result` before returning anything, so this is safe to call
  /// speculatively on every navigation event.
  Future<bool> _tryExtract(BuildContext context, InAppWebViewController controller) async {
    final raw = await controller.evaluateJavascript(source: MvsFinesExtractor.extractJs);
    final fines = MvsFinesExtractor.parse(raw);
    if (fines == null || !context.mounted) return false;
    Navigator.pop(context, fines);
    return true;
  }
}

class _UnavailableView extends StatelessWidget {
  final VoidCallback onRetry;

  const _UnavailableView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textSecondary),
            AppSpacers.verticalMedium,
            Text(
              S.of(context).fines_mvs_unavailable_title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            AppSpacers.verticalSmall,
            Text(
              S.of(context).fines_mvs_unavailable_message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacers.verticalMedium,
            OutlinedButton(onPressed: onRetry, child: Text(S.of(context).fines_mvs_retry)),
          ],
        ),
      ),
    );
  }
}
