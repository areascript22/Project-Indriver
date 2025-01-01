import 'package:driver_app/shared/models/driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class HomeRealtimeDBService {
  // Function to write location to Firebase
  static Future<void> updateLocationInFirebase(Position position, Driver driver) async {
    final Logger logger = Logger();
    try {
      String? driverId = FirebaseAuth.instance.currentUser?.uid;
      if (driverId == null) {
        logger.i("User is not authenticated");
        return;
      }
      final DatabaseReference databaseRef =
          FirebaseDatabase.instance.ref().child('drivers/$driverId');

      // Define the driver data
      Map<String, dynamic> driverData = {
        "status": "pending",
        "duration": "NA",
        "information": {
          "name": driver.name,
          "rating":driver.ratings.totalRatingScore,
          "phone": driver.phone,
          "vehicleModel": driver.vehicle.model,
          "profilePicture": driver.profilePicture,
          "carRegistrationNumber":
              driver.vehicle.carRegistrationNumber,
        },
        "location": {
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
      };

      await databaseRef.set(driverData);

      logger.i(
          "Location updated in Firebase: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      logger.e("Error writing location to Firebase: $e");
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
