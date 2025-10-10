import 'dart:convert';
import 'package:core/config/src/usecases/extract_tokens_usecase.dart';
import 'package:fines_plus/features/registration/data/models/tokens.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';



class ExtractTokensUseCase implements IExtractTokensUseCase {
  final TokensRepository repository;

  ExtractTokensUseCase(this.repository);

  @override
  Future<Tokens> execute(InAppWebViewController webController) async {
    final fbUserRaw = await webController.evaluateJavascript(source: 'localStorage.getItem("fbUser");');
    final edUserRaw = await webController.evaluateJavascript(source: 'localStorage.getItem("edUser");');
    final cookieRaw = await webController.evaluateJavascript(source: 'document.cookie;');

    final fbUserStr = fbUserRaw?.toString() ?? '';
    final edUserStr = edUserRaw?.toString() ?? '';
    final cookieString = cookieRaw?.toString() ?? '';

    String edriveToken = '';
    if (fbUserStr.isNotEmpty) {
      try {
        final fbObj = jsonDecode(fbUserStr);
        edriveToken = fbObj['stsTokenManager']?['accessToken'] ?? '';
      } catch (_) {}
    }
    if (edriveToken.isEmpty && edUserStr.isNotEmpty) {
      try {
        final edObj = jsonDecode(edUserStr);
        edriveToken = (edObj['id'] ?? edObj['token'] ?? edObj['accessToken'] ?? '').toString();
      } catch (_) {}
    }

    String csrf = '';
    final match = RegExp(r'_csrf=([^;]+)').firstMatch(cookieString);
    if (match != null) csrf = Uri.decodeComponent(match.group(1)!);

    final tokens = Tokens(
      edriveToken: edriveToken,
      csrf: csrf,
      cookie: cookieString,
      fbUser: fbUserStr,
    );

    await repository.saveTokens(tokens);
    return tokens;
  }
}
