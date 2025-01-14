import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class RideRequestService {
  //To book position, driver is added to queue
  static Future<void> bookDriverPositionInQueue({
    required String idUsuario,
    required bool status,
  }) async {
    final Logger logger = Logger();
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('positions/$idUsuario');

    // Prepare the data to write
    final Map<String, dynamic> data = {
      'Status': status,
      'Timestamp': ServerValue.timestamp, // Add Firebase server timestamp
    };

    // Set or update the data
    await dbRef.set(data).then((_) {
      logger.i('Data successfully updated for $idUsuario!');
    }).catchError((error) {
      logger.e('Failed to update data: $error');
    });
  }

//Update "status" field under 'driver/driverId' node
  static Future<void> updateDriverStatus(String driverId, String status) async {
    final Logger logger = Logger();
    try {
      final DatabaseReference databaseRef =
          FirebaseDatabase.instance.ref('drivers/$driverId/status');
      // Update the status
      await databaseRef.set(status);
      logger.i(
          'Successfully updated driver status to :$status for driverId: $driverId');
    } catch (e) {
      logger.e('Failed to update driver status: $e');
    }
  }

  //To Free Up driver position in QUeue
  static Future<void> freeUpDriverPositionInQueue() async {
    final logger = Logger();
    //get driver id
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      logger.e("Driver is not authenticated..");
      return;
    }
    try {
      final DatabaseReference dbRef =
          FirebaseDatabase.instance.ref('positions/$uid');
      await dbRef.remove();
      logger.i('Position removed successfully for UID: $uid');
    } catch (e, stackTrace) {
      logger.e('Failed to remove position for UID: $uid, $e, $stackTrace');
    }
  }

  // Static function to remove the 'passenger' node
  static Future<void> removePassengerInfo() async {
    final logger = Logger();
    //get driver id
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      logger.e("Driver is not authenticated..");
      return;
    }

    try {
      // Reference to the 'drivers/driverId/passenger' node
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("drivers/$uid/passenger");

      // Remove the 'passenger' node
      await ref.remove();
      logger.i("Passenger node removed successfully.");
    } catch (e) {
      // Handle any errors
      logger.e("Error removing passenger node: $e");
    }
  }
}
