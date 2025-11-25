import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final FirebaseAuth auth;
  final FlutterSecureStorage storage;

  RegistrationCubit({required this.auth, required this.storage}) : super(const RegistrationState());

  Future<void> checkEmail(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      emit(state.copyWith(isExistingUser: false, emailError: null));
      return;
    }

    try {
      final methods = await auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        emit(state.copyWith(isExistingUser: true, emailError: null));
      } else {
        emit(state.copyWith(isExistingUser: false, emailError: null));
      }
    } on FirebaseAuthException catch (_) {
      emit(state.copyWith(emailError: S.current.email_verification_error));
    }
  }

  Future<void> register(String email, String password) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      if (state.isExistingUser) {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        emit(state.copyWith(isLoading: false, isRegistered: true));
      } else {
        final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);

        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'isSubscribed': false,
        });

        emit(state.copyWith(isLoading: false, isRegistered: true));
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = S.current.incorrect_password;
          break;
        case 'email-already-in-use':
          message = S.current.email_already_exists;
          break;
        case 'user-not-found':
          message = S.current.user_not_found;
          break;
        case 'invalid-email':
          message = S.current.incorrect_email_address;
          break;
        default:
          message = e.message ?? e.code;
      }
      emit(state.copyWith(isLoading: false, error: message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    await storage.write(key: 'savedEmail', value: email);
    await storage.write(key: 'savedPassword', value: password);
  }

  Future<Map<String, String>> loadCredentials() async {
    final email = await storage.read(key: 'savedEmail') ?? '';
    final password = await storage.read(key: 'savedPassword') ?? '';
    return {'email': email, 'password': password};
  }

  void toggleLoginMode() {
    emit(state.copyWith(isExistingUser: !state.isExistingUser, emailError: null, error: null));
  }

  Future<bool> checkSubscription() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!doc.exists) return false;

    final data = doc.data()!;

    final isSubscribed = data["isSubscribed"] ?? false;
    final end = data["subscriptionEndDate"];
    if (isSubscribed && end != null) {
      final endDate = DateTime.fromMillisecondsSinceEpoch(end);
      if (DateTime.now().isBefore(endDate)) return true;
    }

    final isTrial = data["isTrial"] ?? false;
    final trialEnd = data["trialEndDate"];
    if (isTrial && trialEnd != null) {
      final tEnd = DateTime.fromMillisecondsSinceEpoch(trialEnd);
      if (DateTime.now().isBefore(tEnd)) return true;
    }

    return false;
  }
}
