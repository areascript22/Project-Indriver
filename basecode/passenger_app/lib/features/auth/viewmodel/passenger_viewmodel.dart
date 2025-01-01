import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';
import 'package:passenger_app/features/auth/model/api_status_code.dart';
import 'package:passenger_app/features/auth/repositories/passenger_servide.dart';

class PassengerViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  String? phoneNumber;
  String? verificationId;
  bool _loading = false;
  PassengerModel? passenger;

  //GETTTERS
  bool get loading => _loading;

  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

//Get Passenger data
  Future<bool> getPassengerData() async {
    loading = true;
    var response = PassengerService.getUserData();
    if (response is Succes) {
      var temp = response as Succes;
      passenger = temp.response as PassengerModel;
      loading = false;
      return true;
    }

    if (response is Failure) {}

    loading = false;
    return false;
  }

  Future<Object> getAuthenticatedPassengerData() async {
    return PassengerService.getUserData();
  }

  //Save Pasesnger data in Firestore
  Future<bool> savePassengerDataInFirestore(PassengerModel passenger) async {
    loading = true;
    bool response =
        await PassengerService.savePassengerDataInFirestore(passenger);
    loading = false;
    return response;
  }

// Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile, String uid) async {
    loading = true;
    String? response = await PassengerService.uploadImage(imageFile, uid);
    loading = false;
    return response;
  }

//To verifiy code SMS
  void verifySms(
    String smsCode,
    BuildContext context,
  ) async {
    loading = true;
    if (verificationId == null) {
      loading = false;
      return;
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: smsCode,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      loading = false;

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      logger.i("Error...... ${e.toString()}");
      loading = false;
    }
    loading = false;
  }
}
