import 'package:fines_plus/features/registration/data/models/tokens.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

abstract class IExtractTokensUseCase {
  Future<Tokens> execute(InAppWebViewController webController);
}

