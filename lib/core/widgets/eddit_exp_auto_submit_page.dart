// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:auto_route/auto_route.dart';
import 'package:core/config/app_urls.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:webview_feature/utils/webview_form_injector.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class EditExpAutoSubmitPage extends StatefulWidget {
  final int expId;
  final Map<String, String> fieldValues;

  const EditExpAutoSubmitPage({super.key, required this.expId, required this.fieldValues});

  @override
  State<EditExpAutoSubmitPage> createState() => _EditExpAutoSubmitPageState();
}

class _EditExpAutoSubmitPageState extends State<EditExpAutoSubmitPage> {
  late final WebViewController _controller;
  bool _didInject = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Console', onMessageReceived: (message) => debugPrint('Console: ${message.message}'))
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: _onPageFinished));

 
    _controller.loadRequest(Uri.parse(AppUrls.addExp(widget.expId)));

 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openGoogleAuth();
    });
  }

 
  Future<void> _onPageFinished(String url) async {
    debugPrint('Page finished: $url');

 
    if (url.contains('/auth/')) {
      try {
        await _controller.runJavaScript("""
          (function(){
            var all = document.querySelectorAll('button, a, input');
            var out = [];
            for (var i=0;i<all.length;i++){
              out.push(all[i].outerHTML);
            }
            Console.postMessage(out.join("\\n---\\n"));
          })();
        """);
        debugPrint('Logged buttons on /auth/');
      } catch (e) {
        debugPrint('Error logging buttons: $e');
      }
    }

  
    if ((url.contains('/addexp/') || url.contains('/exps/')) && !_didInject) {
      try {
        final js = WebViewFormInjector.buildFillAndSubmitJs(widget.fieldValues);
        await _controller.runJavaScript(js);
        _didInject = true;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The fields are filled')));
      } catch (e) {
        debugPrint('Inject error: $e');
      }
    }
  }

  
  Future<void> _openGoogleAuth() async {
    const authUrl = AppUrls.auth;
    try {
      await launchUrlString(authUrl, mode: LaunchMode.externalApplication);
     
      _controller.reload();
    } catch (e) {
      debugPrint('Error opening Google Auth: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).publish),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _controller.reload())],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
