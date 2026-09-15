
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_data/core_data.dart';
import 'package:fines_plus/features/vehicle/data/models/car_info_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class CarInfoLocalDataSource {
  CarInfoLocalDataSource(this.prefs,this.firestore, this.auth);
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final SharedPrefsManager prefs;

  static const _carKey = 'car_number';
  static const _techKey = 'tech_passport';
  static const _seriesKey = 'doc_series';
  static const _numberKey = 'doc_number';
  static const _carIdKey = 'car_id';

  Future<void> saveCarInfo(CarInfoModel model) async {
    final car = model.carNumber.trim();
    final tech = model.techPassport.trim();

    await prefs.setString(_carKey, car);
    await prefs.setString(_techKey, tech);

    if (tech.length == 9) {
      final series = tech.substring(0, 3);
      final number = tech.substring(3);
      await prefs.setString(_seriesKey, series);
      await prefs.setString(_numberKey, number);

      debugPrint("Saved tech passport split: series=$series, number=$number");
    }

    await _mirrorToCarDoc({'carNumber': car, 'techPassport': tech});

    debugPrint("Saved car info: number=$car, tech=$tech");
  }

  /// Merges fields onto the canonical `users/{uid}/cars/{carId}` doc so the
  /// plate/tech-passport stay visible next to the expenses/maintenance/
  /// reminders/analytics data already keyed by that same carId.
  Future<void> _mirrorToCarDoc(Map<String, dynamic> fields) async {
    final user = auth.currentUser;
    final carId = prefs.getString(_carIdKey) ?? '';
    if (user == null || carId.isEmpty) return;

    try {
      await firestore.collection('users').doc(user.uid).collection('cars').doc(carId).set({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('_mirrorToCarDoc failed: $e');
    }
  }

  Future<CarInfoModel> getCarInfo() async {
    final car = prefs.getString(_carKey) ?? '';
    final tech = prefs.getString(_techKey) ?? '';
    final series = prefs.getString(_seriesKey) ?? '';
    final number = prefs.getString(_numberKey) ?? '';
    final carId = prefs.getString(_carIdKey) ?? '';

    debugPrint("Loaded car info: number=$car, tech=$tech, series=$series, num=$number, carId=$carId");

    return CarInfoModel(
      carNumber: car,
      techPassport: tech,
      ownerId: '',
      carId: carId,
    );
  }

  /// Returns the stable id of the signed-in user's (single, for now) car,
  /// generating and persisting one via a Firestore auto-id if this is the
  /// first time — this is what lets a car with no plate yet (a "skip"
  /// default car) still have a stable Firestore key for its expenses,
  /// maintenance, reminders and analytics data.
  ///
  /// Pre-update installs never had a carId: their car doc's Firestore id
  /// literally *was* the plate number (`users/{uid}/cars/{plate}`), and
  /// their expenses/scheduleTasks/reminders/analytics are still keyed by
  /// that same string. So before minting a brand-new id (which would orphan
  /// all of that), this checks for such a pre-existing car doc and adopts
  /// its id instead — no data has to move, since that doc's id becomes the
  /// carId as-is.
  Future<String> ensureCarId() async {
    final existing = prefs.getString(_carIdKey) ?? '';
    if (existing.isNotEmpty) return existing;

    final user = auth.currentUser;
    if (user == null) return '';

    final carsCollection = _carsCollection(user.uid);
    final userDocRef = firestore.collection('users').doc(user.uid);

    // This lookup's outcome must be trustworthy before deciding whether to
    // mint a brand-new id: falling through to "mint new" on a mere network
    // hiccup here — rather than genuinely confirming no pre-existing car
    // exists — would permanently orphan a real user's data (the new id
    // gets persisted locally, so the check never runs again). So a failed
    // lookup returns empty and leaves nothing persisted, letting the next
    // call retry from scratch instead.
    DocumentSnapshot<Map<String, dynamic>>? preferred;
    QuerySnapshot<Map<String, dynamic>>? fallbackList;
    try {
      // Prefer the car the user actually had active (recorded on the user
      // doc) over an arbitrary one — otherwise a multi-car garage user who
      // loses local prefs (reinstall, cleared data, new device) would be
      // silently switched to whichever car Firestore happens to return
      // first, not the one they were using.
      final userDoc = await userDocRef.get();
      final activeCarId = userDoc.data()?['activeCarId'] as String?;
      if (activeCarId != null && activeCarId.isNotEmpty) {
        final activeDoc = await carsCollection.doc(activeCarId).get();
        if (activeDoc.exists) preferred = activeDoc;
      }
      if (preferred == null) {
        fallbackList = await carsCollection.limit(1).get();
      }
    } catch (e) {
      debugPrint('ensureCarId: failed to check for a pre-existing car doc, will retry next call: $e');
      return '';
    }

    final doc = preferred ?? (fallbackList != null && fallbackList.docs.isNotEmpty ? fallbackList.docs.first : null);

    if (doc != null) {
      final data = doc.data() ?? <String, dynamic>{};
      final carId = doc.id;
      final carNumber = (data['carNumber'] as String?) ?? doc.id;
      final techPassport = (data['techPassport'] as String?) ?? '';

      await prefs.setString(_carIdKey, carId);
      await prefs.setString(_carKey, carNumber);
      await prefs.setString(_techKey, techPassport);
      if (techPassport.length == 9) {
        await prefs.setString(_seriesKey, techPassport.substring(0, 3));
        await prefs.setString(_numberKey, techPassport.substring(3));
      }

      try {
        await doc.reference.set({
          'carId': carId,
          'carNumber': carNumber,
          if (!data.containsKey('createdAt')) 'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await userDocRef.set({'activeCarId': carId}, SetOptions(merge: true));
      } catch (e) {
        // The adoption itself (prefs + confirmed doc id) already succeeded
        // and is what matters; this backfill write is best-effort.
        debugPrint('ensureCarId: adopted $carId but failed to backfill its doc: $e');
      }

      debugPrint('ensureCarId: adopted pre-existing car doc $carId');
      return carId;
    }

    final carDocRef = carsCollection.doc();
    final carId = carDocRef.id;

    await prefs.setString(_carIdKey, carId);

    try {
      await carDocRef.set({
        'carId': carId,
        'isDefault': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await userDocRef.set({
        'activeCarId': carId,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ensureCarId: failed to write car doc to Firestore: $e');
    }

    return carId;
  }

  Future<void> saveCarNumber(String v) async {
    final car = v.trim();
    await prefs.setString(_carKey, car);
    await _mirrorToCarDoc({'carNumber': car});
  }

  Future<void> saveTechPassport(String v) async {
    final value = v.trim().toUpperCase();
    await prefs.setString(_techKey, value);

    if (value.length == 9) {
      final series = value.substring(0, 3);
      final number = value.substring(3);
      await prefs.setString(_seriesKey, series);
      await prefs.setString(_numberKey, number);

      debugPrint("Saved tech passport split (via saveTechPassport): series=$series, number=$number");
    }

    await _mirrorToCarDoc({'techPassport': value});
  }

  Future<void> saveMake(String make) async => _mirrorToCarDoc({'make': make});

  Future<void> savePhotoUrl(String url) async => _mirrorToCarDoc({'photoUrl': url});

  Future<void> saveFcmToken(String token) async => _mirrorToCarDoc({'fcmToken': token});

Future<void> clearCarInfo() async {
    await prefs.remove(_carKey);
    await prefs.remove(_techKey);
    await prefs.remove(_seriesKey);
    await prefs.remove(_numberKey);
    await prefs.remove(_carIdKey);


  }

  CollectionReference<Map<String, dynamic>> _carsCollection(String uid) =>
      firestore.collection('users').doc(uid).collection('cars');

  /// Looks up a pre-existing car doc by its exact `carNumber`, so re-typing
  /// a plate on a new device (which starts with a brand-new, empty `carId`)
  /// can reattach to that car's real `carId` instead of silently relabeling
  /// the new empty one and orphaning the old car's expenses/etc.
  Future<CarInfoModel?> findCarByNumber(String carNumber, {String? excludeCarId}) async {
    final user = auth.currentUser;
    if (user == null || carNumber.isEmpty) return null;

    final snap = await _carsCollection(user.uid).where('carNumber', isEqualTo: carNumber).limit(2).get();
    final candidates = snap.docs.where((d) => d.id != excludeCarId);
    if (candidates.isNotEmpty) {
      final match = candidates.first;
      final data = match.data();
      debugPrint('findCarByNumber: matched real car doc ${match.id} for $carNumber');
      return CarInfoModel(
        carNumber: (data['carNumber'] as String?) ?? '',
        techPassport: (data['techPassport'] as String?) ?? '',
        ownerId: user.uid,
        carId: match.id,
        make: (data['make'] as String?) ?? '',
        photoUrl: (data['photoUrl'] as String?) ?? '',
      );
    }

    // Pre-carId installs used the plate itself as the Firestore doc id, and
    // some never wrote any fields onto that parent doc — only its
    // expenses/scheduleTasks subcollections — so it's a "phantom" doc that
    // never shows up in the collection query above. Probe for that directly.
    if (carNumber != excludeCarId) {
      final legacyRef = _carsCollection(user.uid).doc(carNumber);
      final legacyExpenses = await legacyRef.collection('expenses').limit(1).get();
      debugPrint('findCarByNumber: legacy phantom-doc probe for $carNumber found ${legacyExpenses.docs.length} expense(s)');
      if (legacyExpenses.docs.isNotEmpty) {
        try {
          await legacyRef.set({
            'carId': carNumber,
            'carNumber': carNumber,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('findCarByNumber: failed to backfill legacy car doc $carNumber: $e');
        }
        return CarInfoModel(carNumber: carNumber, techPassport: '', ownerId: user.uid, carId: carNumber);
      }
    }

    // Ukrainian plates deliberately only use letters that look identical in
    // Latin and Cyrillic (A/А, B/В, C/С, E/Е, H/Н, K/К, M/М, O/О, P/Р, T/Т,
    // X/Х) — a very old install (or a Cyrillic keyboard autocorrecting the
    // input) could have saved the exact same-looking plate as Cyrillic text,
    // which is a completely different, otherwise-invisible Firestore doc id.
    final cyrillicVariant = _toCyrillicHomoglyph(carNumber);
    if (cyrillicVariant != carNumber && cyrillicVariant != excludeCarId) {
      final cyrillicRef = _carsCollection(user.uid).doc(cyrillicVariant);
      final cyrillicExpenses = await cyrillicRef.collection('expenses').limit(1).get();
      debugPrint(
        'findCarByNumber: Cyrillic-lookalike probe for $carNumber ($cyrillicVariant) found ${cyrillicExpenses.docs.length} expense(s)',
      );
      if (cyrillicExpenses.docs.isNotEmpty) {
        try {
          await cyrillicRef.set({
            'carId': cyrillicVariant,
            'carNumber': carNumber,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('findCarByNumber: failed to backfill Cyrillic-lookalike car doc $cyrillicVariant: $e');
        }
        return CarInfoModel(carNumber: carNumber, techPassport: '', ownerId: user.uid, carId: cyrillicVariant);
      }
    }

    return null;
  }

  static const _latinToCyrillicHomoglyphs = {
    'A': 'А', 'B': 'В', 'C': 'С', 'E': 'Е', 'H': 'Н',
    'I': 'І', 'K': 'К', 'M': 'М', 'O': 'О', 'P': 'Р', 'T': 'Т', 'X': 'Х',
  };

  String _toCyrillicHomoglyph(String latin) =>
      latin.split('').map((c) => _latinToCyrillicHomoglyphs[c] ?? c).join();

  /// All of the signed-in user's cars — the "garage".
  Stream<List<CarInfoModel>> streamCars() {
    final user = auth.currentUser;
    // Stream.empty() never emits at all, which left GarageCubit's
    // isLoading stuck true forever for a signed-out user (e.g. someone on
    // the no-account free trial) — emit the (correct) empty list once
    // instead so the "no cars yet" UI actually renders.
    if (user == null) return Stream.value(const []);

    return _carsCollection(user.uid).orderBy('createdAt').snapshots().map(
      (snap) => snap.docs.map((d) {
        final data = d.data();
        return CarInfoModel(
          carNumber: (data['carNumber'] as String?) ?? '',
          techPassport: (data['techPassport'] as String?) ?? '',
          ownerId: user.uid,
          carId: d.id,
          make: (data['make'] as String?) ?? '',
          photoUrl: (data['photoUrl'] as String?) ?? '',
        );
      }).toList(),
    );
  }

  /// Adds a new car to the garage (its own Firestore auto-id) without
  /// touching whichever car is currently active locally.
  Future<CarInfoModel> addCar({
    String carNumber = '',
    String techPassport = '',
    String make = '',
    String photoUrl = '',
  }) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Not signed in');

    final docRef = _carsCollection(user.uid).doc();
    final car = CarInfoModel(
      carNumber: carNumber.trim(),
      techPassport: techPassport.trim().toUpperCase(),
      ownerId: user.uid,
      carId: docRef.id,
      make: make,
      photoUrl: photoUrl,
    );

    await docRef.set({
      'carId': car.carId,
      'carNumber': car.carNumber,
      'techPassport': car.techPassport,
      'make': car.make,
      'photoUrl': car.photoUrl,
      'isDefault': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return car;
  }

  /// Merges fields onto a specific car's doc — used to edit a garage car
  /// that is NOT the currently active one (the active car's carNumber/
  /// techPassport are kept in sync via [saveCarNumber]/[saveTechPassport]
  /// instead, which also update the local cache).
  Future<void> updateCarFields(
    String carId, {
    String? carNumber,
    String? techPassport,
    String? make,
    String? photoUrl,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    final fields = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
    if (carNumber != null) fields['carNumber'] = carNumber.trim();
    if (techPassport != null) fields['techPassport'] = techPassport.trim().toUpperCase();
    if (make != null) fields['make'] = make;
    if (photoUrl != null) fields['photoUrl'] = photoUrl;

    await _carsCollection(user.uid).doc(carId).set(fields, SetOptions(merge: true));
  }

  /// Makes [car] the active one: local cache (prefs) + `activeCarId` on the
  /// user doc switch to it, so every carNumber/techPassport-reading screen
  /// picks it up.
  Future<void> switchActiveCar(CarInfoModel car) async {
    await prefs.setString(_carIdKey, car.carId);
    await prefs.setString(_carKey, car.carNumber);
    await prefs.setString(_techKey, car.techPassport);

    if (car.techPassport.length == 9) {
      await prefs.setString(_seriesKey, car.techPassport.substring(0, 3));
      await prefs.setString(_numberKey, car.techPassport.substring(3));
    } else {
      await prefs.remove(_seriesKey);
      await prefs.remove(_numberKey);
    }

    final user = auth.currentUser;
    if (user != null) {
      await firestore.collection('users').doc(user.uid).set({
        'activeCarId': car.carId,
      }, SetOptions(merge: true));
    }
  }

  /// Deletes a car and all of its data: the car doc itself, its
  /// `expenses`/`scheduleTasks` subcollections, and the (pre-existing,
  /// carId-keyed but top-level) `reminders`/`analytics` collections.
  ///
  /// The car doc + its subcollections are committed as a single Firestore
  /// batch: either ALL of it disappears together, or NONE of it does. A
  /// per-document delete loop previously left the door open for a partial
  /// failure (e.g. a permission-denied error partway through) to delete
  /// some expenses while leaving the car itself in place — a real instance
  /// of exactly that data loss is why this is now atomic.
  ///
  /// Cleanup of the two legacy top-level collections stays best-effort:
  /// those predate any per-user Firestore rule and may reject the delete
  /// outright even when nothing is there to delete, and that must not make
  /// the whole action look like it failed once the car itself is gone.
  Future<void> deleteCarDoc(String carId) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Not signed in');

    final carRef = _carsCollection(user.uid).doc(carId);

    // Must run BEFORE the car doc is deleted below: their security rules
    // gate access on `exists(.../cars/{carId})`, so once the car is gone
    // these would permanently fail and leave orphaned documents behind.
    try {
      final remindersRef = firestore.collection('reminders').doc(carId);
      final remindersSnap = await remindersRef.collection('items').get();
      for (final doc in remindersSnap.docs) {
        await doc.reference.delete();
      }
      await remindersRef.delete();
    } catch (e) {
      debugPrint('deleteCarDoc: failed to clean up reminders for $carId: $e');
    }

    try {
      final analyticsRef = firestore.collection('analytics').doc(carId);
      final analyticsSnap = await analyticsRef.collection('months').get();
      for (final doc in analyticsSnap.docs) {
        await doc.reference.delete();
      }
      await analyticsRef.delete();
    } catch (e) {
      debugPrint('deleteCarDoc: failed to clean up analytics for $carId: $e');
    }

    final batch = firestore.batch();
    for (final sub in ['expenses', 'scheduleTasks']) {
      final snap = await carRef.collection(sub).get();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
    }
    batch.delete(carRef);
    await batch.commit();
  }

  /// Clears the local "active car" entirely so the next [ensureCarId] call
  /// creates a fresh default one — used after deleting the last car in the
  /// garage.
  Future<String> resetToNewDefaultCar() async {
    await clearCarInfo();
    return ensureCarId();
  }

}
