import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/features/request_driver/model/ride_location.dart';

class RequestDriverService{

   //Get first available drivre under "positions" node
  static Future<String?> getFirstDriverKeyOrderedByTimestamp() async {
    final Logger logger = Logger();
    try {
      final DatabaseReference driversRef =
          FirebaseDatabase.instance.ref('positions');
      final DataSnapshot snapshot =
          await driversRef.orderByChild('Timestamp').limitToFirst(1).get();

      if (snapshot.exists && snapshot.value != null) {
        final DataSnapshot child = snapshot.children.first;
        return child.key; // Return only the key of the first driver
      } else {
        logger.i("No drivers found.");
        return null;
      }
    } catch (e) {
      logger.e("Error fetching driver: $e");
      return null;
    }
  }

  //Get driver data by id, under "drivers" node
  static Future<Map<String, dynamic>?> getDriverInformationById(
      String driverId) async {
    final Logger logger = Logger();
    try {
      final DatabaseReference driversRef =
          FirebaseDatabase.instance.ref('drivers');
      final DataSnapshot snapshot = await driversRef.child(driverId).get();
      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        logger.e("No data found for driver ID: $driverId");
        return null;
      }
    } catch (e) {
      logger.e("Error fetching driver data: $e");
      return null;
    }
  }

  //Add request data under "drivers/key" node
  static Future<void> updatePassengerNode(
      String driverId, RideLocation passengerData) async {
    final Logger logger = Logger();
    try {
      // Reference to the main node (e.g., a driver ID or any other node ID)
      final DatabaseReference mainNodeRef =
          FirebaseDatabase.instance.ref('drivers/$driverId');

      // Update the "passenger" node under the specific main node
      await mainNodeRef.child('passenger').set(passengerData.toJson());

      logger.i("Passenger node updated successfully.");
    } catch (e) {
      logger.e("Error updating passenger node: $e");
    }
  }
  
}