import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class PendingRideRequestService {
  // Static function to write data to Firebase Realtime Database
  static Future<bool> addDriverToRideRequest(
      String passengerId, String driverId) async {
    final logger = Logger();
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      String path = 'driver_requests/$passengerId';
      Map<String, String> data = {
        'driver': driverId,
      };
      await ref.child(path).update(data);

      logger.i('Data successfully written to $path');
      return true;
    } catch (e) {
      logger.e('Error writing to Firebase: $e');
      return false;
    }
  }
}
