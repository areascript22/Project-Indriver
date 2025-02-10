import 'dart:async';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class HomeRealtimeDBService {
  // Function to write location to Firebase
  static Future<void> writeOrUpdateLocationInFirebase(
      Position position, GUser driver) async {
    final Logger logger = Logger();
    try {
      // Get the authenticated driver's ID
      String? driverId = FirebaseAuth.instance.currentUser?.uid;
      if (driverId == null) {
        logger.i("User is not authenticated");
        return;
      }

      // Reference to the driver's node in Firebase
      final DatabaseReference databaseRef =
          FirebaseDatabase.instance.ref().child('drivers/$driverId');

      // Check if the data already exists in Firebase
      DataSnapshot snapshot = await databaseRef.get();

      if (!snapshot.exists) {
        // Write the initial full data
        Map<String, dynamic> driverData = {
          "status": "pending",
          "duration": "NA",
          "information": {
            "name": driver.name,
            "rating": driver.ratings.totalRatingScore,
            "phone": driver.phone,
            "vehicleModel": driver.vehicle!.model,
            "profilePicture": driver.profilePicture,
            "carRegistrationNumber": driver.vehicle!.carRegistrationNumber,
          },
          "location": {
            "latitude": position.latitude,
            "longitude": position.longitude,
          },
        };

        await databaseRef.set(driverData);
        logger.i("Initial data written to Firebase");
      } else {
        // Update only the location field
        Map<String, dynamic> locationData = {
          "location": {
            "latitude": position.latitude,
            "longitude": position.longitude,
          },
        };

        await databaseRef.update(locationData);
        //   logger.i(
        //       "Location updated in Firebase: ${position.latitude}, ${position.longitude}");
        //
      }
    } catch (e) {
      logger.e("Error writing/updating location in Firebase: $e");
    }
  }

  //To handler disconection from Datbase
  static Future<void> setOnDisconnectHandler() async {
    try {
      String? driverId = FirebaseAuth.instance.currentUser?.uid;
      if (driverId == null) return;
      //Reference to "drivers" node
      final DatabaseReference databaseRef =
          FirebaseDatabase.instance.ref().child('drivers/$driverId');
      //Reference to "positions" node
      final DatabaseReference positionReference =
          FirebaseDatabase.instance.ref().child('positions/$driverId');

      // Schedule removal of location data when the app disconnects
      await databaseRef.onDisconnect().remove();
      await positionReference.onDisconnect().remove();
      Logger().i("onDisconnect handler set for driverId: $driverId");
    } catch (e) {
      Logger().e("Error setting onDisconnect handler: $e");
    }
  }
}
