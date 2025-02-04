import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class PendingRideRequestService {
  // Static function to write data to Firebase Realtime Database
  static Future<bool> addDriverToRideRequest(
      String passengerId, String driverId) async {
    final logger = Logger();
    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('driver_requests/$passengerId/driver');

      return await ref.runTransaction((currentData) {
        if (currentData == null) {
          return Transaction.success(driverId); // Assign the first driver
        }
        return Transaction.abort(); // Reject other drivers
      }).then((transactionResult) {
        if (transactionResult.committed) {
          logger.i(
              'Driver $driverId successfully assigned to passenger $passengerId');
          return true;
        } else {
          logger.w('Driver $driverId could not be assigned (already taken)');
          return false;
        }
      });
    } catch (e) {
      logger.e('Error writing to Firebase: $e');
      return false;
    }
  }

  //Remove request
  static Future<bool> removeRideRequest(String passengerId) async {
    final logger = Logger();
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('driver_requests/$passengerId');

      await ref.remove();

      logger.i('Ride request for passenger $passengerId removed successfully.');
      return true;
    } catch (e) {
      logger.e('Error removing ride request for passenger $passengerId: $e');
      return false;
    }
  }
}
