import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';

class ReferralCubit extends Cubit<String?> {
  final AppLinks _appLinks;
  final SharedPreferences _prefs;
  
  ReferralCubit(this._appLinks, this._prefs,) : super(null);

  /// Initialization at startup
  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleUri(initialUri);
    }

   // listener for open links
    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });

   // load the saved value
    final savedRef = _prefs.getString('pending_ref');
    if (savedRef != null && savedRef.isNotEmpty) {
      emit(savedRef);
    }
  }

  Future<void> _handleUri(Uri uri) async {
    final ref = uri.queryParameters['ref'];
    if (ref != null && ref.isNotEmpty) {
      await _prefs.setString('pending_ref', ref);
      emit(ref);

      
    }
  }

 /// We get the current ref (for example, during registration)
  String? get currentRef => state;

 /// clear after saving to Firestore during registration
  Future<void> clear() async {
    await _prefs.remove('pending_ref');
    emit(null);
  }
   
  
}
