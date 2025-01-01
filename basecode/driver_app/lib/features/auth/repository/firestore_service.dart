import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/features/auth/model/api_result.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  //GEt Passenger data from Firestore, only is passenger us authenticated
  static Future<Object> getAuthenticatedDriver() async {
    final Logger logger = Logger();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .get();
        if (userData.exists) {
          return Succes(
              code: 200, response: Driver.fromDocument(userData, user.uid));
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
}
