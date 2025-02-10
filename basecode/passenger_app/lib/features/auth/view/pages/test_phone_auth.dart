import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PhoneAuthExample extends StatefulWidget {
  const PhoneAuthExample({super.key});
  @override
  _PhoneAuthExampleState createState() => _PhoneAuthExampleState();
}

class _PhoneAuthExampleState extends State<PhoneAuthExample> {
  final logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String? verificationId; // Store the verificationId here

  void loginWithPhoneNumber() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneController.text.trim(),
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          logger.i("Auto-verification completed!");
        },
        verificationFailed: (FirebaseAuthException e) {
          logger.e("Verification failed: ${e}");
        },
        codeSent: (String verId, int? resendToken) {
          setState(() {
            verificationId = verId; // Store verification ID
          });
          logger.i("OTP sent to ${phoneController.text}");
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      logger.e("Error: $e");
    }
  }

  void verifyOTP() async {
    if (verificationId == null) {
      logger.e("Error: No verification ID stored.");
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      print("User logged in successfully!");
    } catch (e) {
      print("OTP Verification failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: loginWithPhoneNumber,
              child: Text("Send OTP"),
            ),
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: "Enter OTP"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: verifyOTP,
              child: Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
