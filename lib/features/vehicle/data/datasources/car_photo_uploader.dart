import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Picks a photo from the gallery and uploads it to Firebase Storage at
/// `car_photos/{uid}/{carId}.jpg`, returning its public download URL.
/// Returns null if the user cancelled the picker.
class CarPhotoUploader {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndUpload({required String uid, required String carId}) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600);
    if (picked == null) return null;

    final ref = FirebaseStorage.instance.ref('car_photos/$uid/$carId.jpg');
    // A misconfigured bucket/rules can otherwise leave the caller waiting
    // forever instead of failing visibly.
    await ref.putFile(File(picked.path)).timeout(const Duration(seconds: 30));
    return ref.getDownloadURL().timeout(const Duration(seconds: 15));
  }
}
