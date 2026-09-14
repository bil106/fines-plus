import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_start_state.dart';

class AppStartCubit extends Cubit<AppStartState> {
  final SharedPreferences prefs;
  final FirebaseAuth auth;
  final RemoteConfigService remoteConfig;
  final bool isUpdateRequired;

  AppStartCubit({required this.prefs, required this.auth, required this.remoteConfig, required this.isUpdateRequired})
    : super(AppStartLoading());

  Future<void> resolve() async {
    if (isUpdateRequired) {
      emit(AppStartUpdateRequired());
      return;
    }

    final user = auth.currentUser;
    if (user == null) {
      emit(AppStartOnboarding());
      return;
    }

    // A signed-in user always has a car to land on Home with: either they
    // already have one, or CarCubit lazily creates a default (plate-less)
    // one the first time it initializes. No car-specific gate needed here.
    emit(AppStartHome());
  }
}
