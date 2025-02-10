import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/g_user.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';
import 'package:passenger_app/features/auth/model/api_status_code.dart';
import 'package:passenger_app/features/auth/repositories/passenger_servide.dart';

class PassengerViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  final _auth = FirebaseAuth.instance;
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

  //get the current authenticated user
  Future<GUser?> getAuthenticatedPassengerData() async {
    return PassengerService.getUserData();
  }

  //Save Pasesnger data in Firestore
  Future<bool> savePassengerDataInFirestore(GUser passenger) async {
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
  void verifySms(String smsCode, BuildContext context) async {
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

  Future<void> loginWithPhoneNumber(
      String phoneNumber,
      Function(String verificationId) onCodeSent,
      Function(String error) onError) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieve or instant verification (for Android)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<UserCredential> verifyOTP(
      String verificationId, String otpCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );
    return await _auth.signInWithCredential(credential);
  }
}
