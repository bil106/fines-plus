import 'package:core_cubit/cubit/referral/referral_cubit.dart';
import 'package:core_cubit/cubit/registration/registration_state.dart';
import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class RegistrationCubit extends Cubit<RegistrationState> {
  final RegisterUserUseCase registerUser;
  final ReferralCubit referralCubit;
  final FlutterSecureStorage storage;

  RegistrationCubit({
    required this.registerUser,
    required this.referralCubit,
    required this.storage,
  }) : super(RegistrationState());


  Future<void> saveCredentials(String email, String password) async {
    await storage.write(key: 'savedEmail', value: email);
    await storage.write(key: 'savedPassword', value: password);
  }

  
  Future<Map<String, String>> loadCredentials() async {
    final email = await storage.read(key: 'savedEmail') ?? '';
    final password = await storage.read(key: 'savedPassword') ?? '';
    return {
      'email': email,
      'password': password,
    };
  }

  
  Future<void> register(String email, String password) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final partnerId = referralCubit.currentRef;
      await registerUser.execute(RegisterUserParams(
        email: email,
        password: password,
        partnerId: partnerId,
      ));

      // Clear ref
      if (partnerId != null) {
        await referralCubit.clear();
      }

      // ✅ регистрация успешна
      emit(state.copyWith(isLoading: false, isRegistered: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
