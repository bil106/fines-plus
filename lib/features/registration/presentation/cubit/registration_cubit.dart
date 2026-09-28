import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_localization/generated/l10n.dart';
import 'package:fines_plus/env/env.dart';
import 'package:fines_plus/features/registration/presentation/cubit/account_deletion_result.dart';
import 'package:fines_plus/features/registration/presentation/cubit/registration_state.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_info_local_data_source.dart';
import 'package:fines_plus/features/vehicle/data/datasources/car_photo_uploader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final FirebaseAuth auth;
  final FlutterSecureStorage storage;

  RegistrationCubit({required this.auth, required this.storage}) : super(const RegistrationState());

  Future<void> register(String email, String password) async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true, isRegistered: false, error: null));

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
      switch (e.code) {
        case 'wrong-password':
          emit(state.copyWith(isLoading: false, error: S.current.incorrect_password));
          break;
        case 'email-already-in-use':
          emit(state.copyWith(isLoading: false, emailError: S.current.email_already_exists));
          break;
        case 'user-not-found':
          emit(state.copyWith(isLoading: false, emailError: S.current.user_not_found));
          break;
        case 'invalid-email':
          emit(state.copyWith(isLoading: false, emailError: S.current.incorrect_email_address));
          break;
        default:
          emit(state.copyWith(isLoading: false, error: e.message ?? e.code));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

 Future<void> saveCredentials(String email, String password) async {
    try {
      await storage.write(key: 'savedEmail', value: email);
      await storage.write(key: 'savedPassword', value: password);
    } catch (e) {
      debugPrint('Failed to save credentials to secure storage: $e');
    }
  }

Future<Map<String, String>> loadCredentials() async {
    try {
      final email = await storage.read(key: 'savedEmail') ?? '';
      final password = await storage.read(key: 'savedPassword') ?? '';
      return {'email': email, 'password': password};
    } catch (e) {
   
      debugPrint('Failed to read credentials from secure storage: $e');
      await storage.deleteAll();
      return {'email': '', 'password': ''};
    }
  }

  void toggleLoginMode() {
    emit(state.copyWith(isExistingUser: !state.isExistingUser, isRegistered: false, emailError: null, error: null));
  }

  Future<bool> checkSubscription() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return false;

    final email = auth.currentUser?.email?.toLowerCase();
    if (email != null && Env.freeAccessEmails.contains(email)) return true;

    try {
      final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!doc.exists) return false;

      final data = doc.data() ?? <String, dynamic>{};

      final isSubscribed = data["isSubscribed"] ?? false;
      final endRaw = data["subscriptionEndDate"];
      if (isSubscribed && endRaw != null) {
        final endDate = _parseFirestoreDate(endRaw);
        if (DateTime.now().isBefore(endDate)) return true;
      }

      final isTrial = data["isTrial"] ?? false;
      final trialRaw = data["trialEndDate"];
      if (isTrial && trialRaw != null) {
        final tEnd = _parseFirestoreDate(trialRaw);
        if (DateTime.now().isBefore(tEnd)) return true;
      }

      return false;
    } catch (_) {
   
      return false;
    }
  }
  DateTime _parseFirestoreDate(dynamic raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }

    if (raw is int) {
    
      try {
        return DateTime.fromMillisecondsSinceEpoch(raw);
      } catch (_) {}
    }

    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;

   
      try {
        final parts = raw.split('.');
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]) ?? 1;
          final month = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          return DateTime(year, month, day);
        }
      } catch (_) {}
    }

    return DateTime.now();
  }

  /// Deletes the signed-in user's cloud data and then the account itself.
  /// Each car goes through [CarInfoLocalDataSource.deleteCarDoc], which also
  /// clears its top-level reminders/analytics. Local caches are the caller's
  /// job, same as on log out.
  Future<AccountDeletionResult> deleteAccount(CarInfoLocalDataSource cars) async {
    final user = auth.currentUser;
    if (user == null) return AccountDeletionResult.failed;

    // Firebase refuses user.delete() unless the last sign-in was within about
    // five minutes. Checking first keeps the data intact in that case instead
    // of wiping it and then failing on the account.
    final lastSignIn = user.metadata.lastSignInTime;
    if (lastSignIn == null || DateTime.now().difference(lastSignIn) > const Duration(minutes: 5)) {
      return AccountDeletionResult.requiresRecentLogin;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final uid = user.uid;
      final firestore = FirebaseFirestore.instance;
      final photos = CarPhotoUploader();

      final carsSnap = await firestore.collection('users').doc(uid).collection('cars').get();
      for (final carDoc in carsSnap.docs) {
        await photos.delete(uid: uid, carId: carDoc.id);
        await cars.deleteCarDoc(carDoc.id);
      }

      final historySnap = await firestore.collection('fines_history').where('userId', isEqualTo: uid).get();
      for (final doc in historySnap.docs) {
        await doc.reference.delete();
      }

      await firestore.collection('users').doc(uid).delete();

      await storage.deleteAll();

      await user.delete();

      emit(state.copyWith(isLoading: false));
      return AccountDeletionResult.deleted;
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(isLoading: false));
      return e.code == 'requires-recent-login'
          ? AccountDeletionResult.requiresRecentLogin
          : AccountDeletionResult.failed;
    } catch (e) {
      debugPrint('deleteAccount failed: $e');
      emit(state.copyWith(isLoading: false));
      return AccountDeletionResult.failed;
    }
  }
}
