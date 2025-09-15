import 'package:core/config/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:webview_feature/utils/webview_form_injector.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DriverTopWebView extends StatefulWidget {
  final String comment;
  final bool offRoad;
  final bool invisible;

  const DriverTopWebView({super.key, required this.comment, required this.offRoad, required this.invisible});

  @override
  State<DriverTopWebView> createState() => _DriverTopWebViewState();
}

class _DriverTopWebViewState extends State<DriverTopWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            final js = WebViewFormInjector.buildFillAndSubmitJs({
              'comment': widget.comment,
              'offRoad': widget.offRoad.toString(),
              'invisible': widget.invisible.toString(),
            });

            await _controller.runJavaScript(js);
          },
        ),
      )
      ..loadRequest(Uri.parse(AppUrls.exps));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Publish')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
