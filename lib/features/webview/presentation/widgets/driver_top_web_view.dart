import 'package:core/config/app_urls.dart';
import 'package:fines_plus/features/webview/data/datasource/webview_form_injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class DriverTopWebView extends StatefulWidget {
  final String comment;
  final bool offRoad;
  final bool invisible;

  const DriverTopWebView({super.key, required this.comment, required this.offRoad, required this.invisible});

  @override
  State<DriverTopWebView> createState() => _DriverTopWebViewState();
}

class _DriverTopWebViewState extends State<DriverTopWebView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publish')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(AppUrls.exps)),
        onWebViewCreated: (controller) {
        },
        onLoadStop: (controller, url) async {
          final js = WebViewFormInjector.buildFillAndSubmitJs({
            'comment': widget.comment,
            'offRoad': widget.offRoad.toString(),
            'invisible': widget.invisible.toString(),
          });

          if (!mounted) return;
          await controller.evaluateJavascript(source: js);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
