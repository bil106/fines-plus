import 'dart:async';

import 'package:core/config/app_urls.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_theme.dart';
import 'package:fines_plus/core/widgets/photo_picker_widget.dart';
import 'package:fines_plus/env/env.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdditionalOptionsWidget extends StatefulWidget {
  final PhotoPickerWidget photoPicker;

  const AdditionalOptionsWidget({super.key, required this.photoPicker});

  @override
  State<AdditionalOptionsWidget> createState() => _AdditionalOptionsWidgetState();
}

class _AdditionalOptionsWidgetState extends State<AdditionalOptionsWidget> {
  bool showOptions = false;
  bool offRoadAccidents = false;
  bool invisibleEvent = false;
  final TextEditingController _commentController = TextEditingController();

  late final WebViewController _webController;
  final cookieManager = WebViewCookieManager();

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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        GestureDetector(
          onTap: () {
            setState(() => showOptions = !showOptions);
          },
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
              Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: widget.photoPicker),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: Text(S.of(context).of_road_accidents),
                value: offRoadAccidents,
                onChanged: (val) => setState(() => offRoadAccidents = val ?? false),
              ),
              CheckboxListTile(
                title: Text(S.of(context).event_invisible),
                value: invisibleEvent,
                onChanged: (val) => setState(() => invisibleEvent = val ?? false),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(labelText: S.of(context).comment, border: const OutlineInputBorder()),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: _loading ? null : _publishComment,
                  child: _loading ? const CircularProgressIndicator() : Text(S.of(context).publish),
                ),
              ),
              if (_status != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_status!, style: textTheme.bodyMedium?.copyWith(color: Colors.green)),
                ),
              const SizedBox(height: 16),
              SizedBox(height: 2300, child: WebViewWidget(controller: _webController)),
            ],
          ),
          crossFadeState: showOptions ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
