import 'package:core_cubit/cubit/referral/referral_cubit.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegistrationCubit extends Cubit<bool> {
  final RegisterUserUseCase registerUser;
  final ReferralCubit referralCubit;
  final SharedPreferences prefs;

  RegistrationCubit({
    required this.registerUser,
    required this.referralCubit,
    required this.prefs,
  }) : super(false);

/// Save the entered data
  Future<void> saveCredentials(String email, String password) async {
    await prefs.setString('savedEmail', email);
    await prefs.setString('savedPassword', password);
  }

  /// Loading saved data
  Map<String, String> loadCredentials() {
    return {
      'email': prefs.getString('savedEmail') ?? '',
      'password': prefs.getString('savedPassword') ?? '',
    };
  }

  Future<void> register(String email, String password) async {
    emit(true); // loading
    try {
      final partnerId = referralCubit.currentRef;
      await registerUser.execute(RegisterUserParams(
        email: email,
        password: password,
        partnerId: partnerId,
      ));

     // Save locally
      await saveCredentials(email, password);

      // Clear ref
      if (partnerId != null) {
        await referralCubit.clear();
      }
    } catch (e) {
      rethrow;
    } finally {
      emit(false); // finished loading
    }
  }
}
