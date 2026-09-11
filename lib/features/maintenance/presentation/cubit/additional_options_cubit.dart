import 'package:fines_plus/features/maintenance/presentation/cubit/additional_options_state.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/registration/data/models/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/config/src/usecases/extract_tokens_usecase.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AdditionalOptionsCubit extends Cubit<AdditionalOptionsState> {
  final IExtractTokensUseCase extractTokensUseCase;
  final TokensRepository tokensRepository;

  AdditionalOptionsCubit({required this.extractTokensUseCase, required this.tokensRepository})
      : super(AdditionalOptionsInitial());

  Future<void> checkSavedTokens() async {
    final tokens = await tokensRepository.getSavedTokens();
    if (tokens != null) {
      emit(AdditionalOptionsTokensPresent());
      debugPrint(S.current.tokens_already_present);
    } else {
      debugPrint(S.current.no_tokens_yet);
    }
  }

  Future<void> extractTokens(InAppWebViewController webController) async {
    emit(AdditionalOptionsLoading());
    try {
      await extractTokensUseCase.execute(webController);
      emit(AdditionalOptionsExtracted());
      debugPrint(S.current.tokens_extracted);
    } catch (e) {
      emit(AdditionalOptionsError('${S.current.failed_extract_tokens}: $e'));
      debugPrint('${S.current.failed_extract_tokens}: $e');
    }
  }
}
