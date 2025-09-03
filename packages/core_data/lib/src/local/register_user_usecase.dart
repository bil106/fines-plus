import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterUserParams {
  final String email;
  final String password;
  final String? partnerId;

  RegisterUserParams({required this.email, required this.password, this.partnerId});
}

class RegisterUserUseCase {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  RegisterUserUseCase({required this.auth, required this.firestore});

  Future<void> execute(RegisterUserParams params) async {
    // Create a user
    final credential = await auth.createUserWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );

    final user = credential.user;
    if (user == null) throw Exception("User not created");

   // Save data to Firestore
    await firestore.collection('users').doc(user.uid).set({
      'email': params.email,
      if (params.partnerId != null) 'partnerId': params.partnerId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Updating partner statistics
    if (params.partnerId != null) {
      await firestore.collection('partnerStats').doc(params.partnerId).set({
        'registrations': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
  }
}
