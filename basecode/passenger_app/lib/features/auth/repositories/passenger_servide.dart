import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';
import 'package:passenger_app/features/auth/model/api_status_code.dart';

class PassengerService {

  //GEt Passenger data from Firestore, only is passenger us authenticated
  static Future<Object> getUserData() async {
    final Logger logger = Logger();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userData.exists) {
          return Succes(
              code: 200, response: PassengerModel.fromFirestore(userData));
        } else {
          return Failure(
              code: 100, errorResponse: 'No existen datos del usuario');
        }
      } else {
        return Failure(code: 100, errorResponse: 'Usuario no registrado');
      }
    } catch (e) {
      logger.e("Error al obtner datos de usuario: $e");
      return Failure(code: 100, errorResponse: 'Error al obtener datos');
    }
  }

  // Upload image to Firebase Storage
  static Future<String?> uploadImage(File imageFile, String uid) async {
    final Logger logger = Logger();
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('ProfileImage/Users/$uid');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      logger.e('Error uploading image: $e');
      return null;
    }
  }

  //Save user data in Firestore
  static Future<bool> savePassengerDataInFirestore(
      PassengerModel passenger) async {
    final Logger logger = Logger();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(passenger.id)
          .set({
        'name': passenger.name,
        'lastName': passenger.lastName,
        'email': passenger.email,
        'phone': passenger.phone,
        'paymentMethods': passenger.paymentMethods,
        'profilePicture': passenger.profilePicture,
        ' rideHistory': '',
        'ratings': {
          'rating': passenger.ratings.rating,
          'ratingCount': passenger.ratings.ratingCount,
          'totalRatingScore': passenger.ratings.totalRatingScore,
        },
        'createdAt': passenger.createdAt,
        'updatedAt': passenger.updatedAt,
      });
      return true;
    } catch (e) {
      logger.e("Error adding user data in Firestore: ${e.toString()}");
      return false;
    }
  }
}
