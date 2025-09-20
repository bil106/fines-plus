import 'dart:async';

import 'package:core/config/app_urls.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/env/env.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdditionalOptionsWidget extends StatefulWidget {
  const AdditionalOptionsWidget({super.key});

  @override
  State<AdditionalOptionsWidget> createState() => _AdditionalOptionsWidgetState();
}

class _AdditionalOptionsWidgetState extends State<AdditionalOptionsWidget> {
  late final WebViewController _webController;
  final cookieManager = WebViewCookieManager();

  final TextEditingController _commentController = TextEditingController();

  bool _loading = false;
  String? _status;

  final String expId = Env.expId;
  final String userid = Env.userid;
  final String cfClearance = Env.cfClearance;
  final String session = "";

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => debugPrint("➡️ Loading $url"),
          onPageFinished: (url) async {
            debugPrint("✅ The page has loaded: $url");

            if (url.contains("addexp/$expId")) {
              final comment = _commentController.text;
              debugPrint("🚀 Insert a comment: $comment");

              await _webController.runJavaScript("""
                console.log("🔹 JS has started");
                let textarea = document.querySelector('textarea[name="comment"]');
                if (textarea) {
                  textarea.value = "$comment";
                  console.log("✍️ Comment inserted");
                } else {
                  console.log("❌ Textarea field not found");
                }

                let form = document.querySelector('form[action*="addexp"]');
                if (form) {
                  form.submit();
                  console.log("📤 The form has been sent.");
                } else {
                  console.log("❌ Form not found");
                }
              """);

              setState(() {
                _status = "✅ ${S.of(context).comment_published}";
                _loading = false;
              });
            }
          },
        ),
      );
  }

  Future<void> _publishComment() async {
    setState(() {
      _loading = true;
      _status = null;
    });

    debugPrint("⚡️ We set cookies...");

    await cookieManager.setCookie(WebViewCookie(name: "userid", value: userid, domain: "driver.top", path: "/"));

    await cookieManager.setCookie(
      WebViewCookie(name: "cf_clearance", value: cfClearance, domain: "driver.top", path: "/"),
    );

    if (session.isNotEmpty) {
      await cookieManager.setCookie(WebViewCookie(name: "session", value: session, domain: "driver.top", path: "/"));
    }

    debugPrint("✅ Cookies have been set. Loading addexp/$expId...");

    await _webController.loadRequest(Uri.parse(AppUrls.addExp(int.parse(expId))));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _commentController,
          decoration: InputDecoration(labelText: S.of(context).comment),
          maxLines: 3,
        ),
        AppSpacers.verticalMediumLarge,
        ElevatedButton(
          onPressed: _loading ? null : _publishComment,
          child: _loading ? const CircularProgressIndicator() : Text(S.of(context).publish),
        ),
        if (_status != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_status!, style: textTheme.black14bold),
          ),

        SizedBox(height: 200, child: WebViewWidget(controller: _webController)),
      ],
    );
  }
}
