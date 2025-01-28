import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/shared/models/passenger.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class RideRequestService {
  //To book position, driver is added to queue
  static Future<bool> bookDriverPositionInQueue({
    required String idUsuario,
  }) async {
    final Logger logger = Logger();
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('positions/$idUsuario');

    // Prepare the data to write
    final Map<String, dynamic> data = {
      'timestamp': ServerValue.timestamp, // Add Firebase server timestamp
    };
    try {
      await dbRef.set(data);
      logger.i('Data successfully updated for $idUsuario!');
      return true;
    } catch (e) {
      logger.e('Failed to update data: $e');
      return false;
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

  //Deleto second driver
  // Static function to remove data from Firebase Realtime Database
  static Future<void> removesecondPassengerInfo() async {
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
          FirebaseDatabase.instance.ref("drivers/$uid/secondPassenger");

      // Remove the 'passenger' node
      await ref.remove();
      logger.i("Passenger node removed successfully.");
    } catch (e) {
      // Handle any errors
      logger.e("Error removing passenger node: $e");
    }
  }

  //Covert second driver to first driver
  static Future<void> addPassengerDataToRequest(Passenger passenger) async {
    final logger = Logger();
    String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Driver is not authenticated..");
      return;
    }
    try {
      final DatabaseReference mainNodeRef =
          FirebaseDatabase.instance.ref('drivers/$driverId/passenger');
      await mainNodeRef.set(passenger.toMap());
      logger.i("Second passenger turned into Passenger: ${passenger.toMap()}");
    } catch (e) {
      logger.e("Error trying to write data: $e");
    }
  }

  // Upload the ride data to Firestore
  static Future<void> uploadRideHistory(RideHistoryModel rideHistory) async {
    final logger = Logger();
    try {
      final rideCollection =
          FirebaseFirestore.instance.collection('ride_history');
      final rideDoc = await rideCollection.add(rideHistory.toMap());
      logger.i("Ride uploaded successfully with ID: ${rideDoc.id}");
    } catch (e) {
      logger.e("Error uploading ride history: $e");
    }
  }
}
