import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/core/widgets/photo_picker_widget.dart';
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
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _publish() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DriverTopWebView(comment: commentController.text, offRoad: offRoadAccidents, invisible: invisibleEvent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              showOptions = !showOptions;
            });
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
                  controller: commentController,
                  decoration: InputDecoration(labelText: S.of(context).comment, border: OutlineInputBorder()),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(onPressed: _publish, child: Text(S.of(context).publish)),
              ),
              const SizedBox(height: 16),
            ],
          ),
          crossFadeState: showOptions ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

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
            final commentJS = widget.comment.replaceAll("'", r"\'");
            final offRoadJS = widget.offRoad ? 'true' : 'false';
            final invisibleJS = widget.invisible ? 'true' : 'false';

            await _controller.runJavaScript("""
            // Click on the "Add record" button 
const addButton = document.querySelector('a[href="/addexp"]'); 
if(addButton) addButton.click(); 

// Completing the comment 
const textarea = document.querySelector('textarea[name="comment"]'); 
if(textarea) textarea.value = '$commentJS'; 

// Example for checkboxes (if there is an input with the necessary name) 
const offRoadCheckbox = document.querySelector('input[name="offRoad"]'); 
if(offRoadCheckbox) offRoadCheckbox.checked = $offRoadJS; 

const invisibleCheckbox = document.querySelector('input[name="invisible"]'); 
if(invisibleCheckbox) invisibleCheckbox.checked = $invisibleJS; 
""");
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
