import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Picks a photo from the gallery and uploads it to Firebase Storage at
/// `car_photos/{uid}/{carId}.jpg`, returning its public download URL.
class CarPhotoUploader {
  final ImagePicker _picker = ImagePicker();

  /// Just the picker step — needed on its own for a brand-new car, which
  /// doesn't have a carId to upload against until after it's created.
  Future<XFile?> pickImage() {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600);
  }

  Future<String> upload({required String uid, required String carId, required File file}) async {
    final ref = FirebaseStorage.instance.ref('car_photos/$uid/$carId.jpg');
    // A misconfigured bucket/rules can otherwise leave the caller waiting
    // forever instead of failing visibly.
    await ref.putFile(file).timeout(const Duration(seconds: 30));
    return ref.getDownloadURL().timeout(const Duration(seconds: 15));
  }

  /// Convenience for the "editing an existing car" flow, where the carId is
  /// already known so picking and uploading can happen in one step.
  Future<String?> pickAndUpload({required String uid, required String carId}) async {
    final picked = await pickImage();
    if (picked == null) return null;
    return upload(uid: uid, carId: carId, file: File(picked.path));
  }
}
