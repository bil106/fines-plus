import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_repository/user_not_signed_in_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CarInfoRemoteDataSource {
  final String baseUrl;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  CarInfoRemoteDataSource(this.firestore, this.auth, {this.baseUrl = "http://localhost:3000/api"});

  Future<List<Map<String, dynamic>>> checkFines({
    required String carNumber,
    required String docSeries,
    required String docNumber,
    required String captchaToken,
  }) async {
    final url = Uri.parse('$baseUrl/fines');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "carNumber": carNumber,
        "docSeries": docSeries,
        "docNumber": docNumber,
        "captchaToken": captchaToken,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Error API: ${response.statusCode} ${response.body}");
    }

    final data = jsonDecode(response.body);

    if (data["fines"] is List) {
      return List<Map<String, dynamic>>.from(data["fines"]);
    } else if (data["fines"] is Map) {
      return [Map<String, dynamic>.from(data["fines"])];
    }
    return [];
  }
Future<void> deleteCar(String carNumber) async {
    final user = auth.currentUser;
    if (user == null) {
      throw UserNotSignedInException();
    }

    final carRef = firestore.collection("cars").doc(carNumber);
    final snapshot = await carRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data?['ownerId'] != user.uid) {
      throw Exception('Not owner of this car');
    }

   
    final expenses = await carRef.collection("expenses").get();
    for (final doc in expenses.docs) {
      await doc.reference.delete();
    }

    
   try {
      await carRef.delete();
    } catch (e) {
      debugPrint("Firestore delete failed: $e");
    }

    debugPrint("Car $carNumber fully deleted");
  }


}
