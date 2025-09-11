import 'package:flutter/material.dart';
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
           
            final _ = widget.comment.replaceAll("'", r"\'");
            await _controller.runJavaScript('');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://driver.top/exps/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Публікація на driver.top')),
      body: WebViewWidget(controller: _controller), 
    );
  }
}
