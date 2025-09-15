// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:core/config/app_urls.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            debugPrint('Page finished: $url');

            // How to edit side → Inject fields
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

                debugPrint('Clicked Google button on /auth/');
              } catch (e) {
                debugPrint('Error clicking Google: $e');
              }
            }

            // How to edit side → Inject fields
            if ((url.contains('/editexp/') || url.contains('/exps/')) && !_didInject) {
              try {
                final js = _buildFillAndSubmitJs(widget.fieldValues);
                await _controller.runJavaScript(js);
                _didInject = true;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('The fields are filled')));
              } catch (e) {
                debugPrint('inject error: $e');
              }
            }
          },
        ),
      );

    _controller.loadRequest(Uri.parse(AppUrls.editExp(widget.expId)));

    // Automatically “presses” the Google button immediately when the page is launched
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openGoogleAuth();
    });
  }

  /// Opening the Google authorization page in the browser
  Future<void> _openGoogleAuth() async {
    const authUrl = AppUrls.auth; // page with "Login with Google" button
    await launchUrlString(authUrl, mode: LaunchMode.externalApplication);

    // After successful login, the user returns to the application
    // WebView will already load the page with the authorized session
    _controller.reload();
  }

  // Future<void> _tryInject(String url) async {
  //     if (_didInject) return;

  //     try {
  //     // If this is a post edit page
  //       if (url.contains('/editexp/')) {
  //         final clickFirstGoogleBtn = """
  //       (function(){
  //         var btn = document.querySelector('button.google-login, a.google-login, [id*="google"]');
  //         if(btn){ btn.click(); return true; } else { return false; }
  //       })();
  //       """;
  //         await _controller.runJavaScript(clickFirstGoogleBtn);
  //       }

  //       // 🔹 New condition: if this is the /auth/ login page and the user is not logged in yet
  //       if (url.contains('/auth/')) {
  //         final clickAuthGoogleBtn = """
  //       (function(){
  //         var btn = document.querySelector('button.google-login, a.google-login, [id*="google"]');
  //         if(btn){ btn.click(); return true; } else { return false; }
  //       })();
  //       """;
  //         await _controller.runJavaScript(clickAuthGoogleBtn);
  //       }

  //       // If this is already a page /exps/ or /editexp/ — inject the form
  //       if (url.contains('/exps/') || url.contains('/editexp/')) {
  //         final js = _buildFillAndSubmitJs(widget.fieldValues);
  //         await _controller.runJavaScript(js);

  //         _didInject = true;
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('The fields are filled'), duration: Duration(seconds: 4)),
  //         );
  //       }
  //     } catch (e) {
  //       debugPrint('inject error: $e');
  //     }
  //   }

  String _escapeForJs(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', r'\n').replaceAll('\r', r'\r');

  String _buildFillAndSubmitJs(Map<String, String> values) {
    final sb = StringBuffer();
    sb.writeln("(function(){");

    values.forEach((name, value) {
      final v = _escapeForJs(value);
      sb.writeln("""
        (function(){
          var el = document.querySelector('[name="${name}"]') || document.getElementById('${name}');
          if (el) {
            var t = (el.type || '').toLowerCase();
            if (t === 'checkbox' || t === 'radio') {
              el.checked = ${v == '1' || v.toLowerCase() == 'true' ? 'true' : 'false'};
              el.dispatchEvent(new Event('change', {bubbles:true}));
            } else {
              el.value = '${v}';
              el.dispatchEvent(new Event('input', {bubbles:true}));
              el.dispatchEvent(new Event('change', {bubbles:true}));
            }
          }
        })();
      """);
    });

    sb.writeln("})();");
    return sb.toString();
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
