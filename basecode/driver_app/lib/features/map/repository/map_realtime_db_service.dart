import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class MapRealtimeDBService {
  // Function to write location to Firebase
  static Future<void> updateLocationInFirebase(Position position) async {
    final Logger logger = Logger();
    try {
      String? driverId = FirebaseAuth.instance.currentUser?.uid;
      if (driverId == null) {
        logger.i("User is not authenticated");
        return;
      }
      final DatabaseReference databaseRef =
          FirebaseDatabase.instance.ref().child('drivers/$driverId/location');
      await databaseRef.set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
      logger.i(
          "Location updated in Firebase: ${position.latitude}, ${position.longitude}");
      databaseRef.onDisconnect().remove();
    } catch (e) {
      logger.e("Error writing location to Firebase: $e");
    }
  }

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
}
