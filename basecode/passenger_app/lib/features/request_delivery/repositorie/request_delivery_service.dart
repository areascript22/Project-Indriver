import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/features/request_delivery/model/delivery_details_model.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';

class RequestDeliveryService {
  // Static function to write this model to Firebase Realtime Database
  static Future<bool> writeToDatabase({
    required String passengerId,
    required PassengerModel passengerModel,
    required DeliveryDetailsModel model,
    required SharedProvider sharedProvider,
  }) async {
    final Logger logger = Logger();
    try {
      // Reference to the "delivery_requests" node in Firebase
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('delivery_requests');
      // Use passengerId as the key for the delivery request
      DatabaseReference passengerRequestRef = ref.child(passengerId);
      // Add timestamp for sorting
      String timestamp = DateTime.now().toIso8601String();
      // Write the data to the passenger's unique node
      await passengerRequestRef.set(
        {
          'information': {
            'name': passengerModel.name,
            'phone': passengerModel.phone,
            'profilePicture': passengerModel.profilePicture,
            'pickUpLocation': sharedProvider.pickUpLocation,
            'dropOffLocation': sharedProvider.dropOffLocation,
            "pickUpCoordenates": {
              "latitude": sharedProvider.pickUpCoordenates!.latitude,
              "longitude": sharedProvider.pickUpCoordenates!.longitude, 
            },
            "dropOffCoordenates": {
              "latitude": sharedProvider.dropOffCoordenates!.latitude,
              "longitude": sharedProvider.dropOffCoordenates!.longitude,
            },
          },
          'details': model.toMap(),
          'status': 'pending',
          'timestamp': timestamp, // Add sortable timestamp here
        },
      );

      logger.i(
          'Delivery request written successfully for passenger ID: $passengerId');
      return true;
    } catch (e) {
      logger.e('Error writing delivery request: $e');
      return false;
    }
  }
}
