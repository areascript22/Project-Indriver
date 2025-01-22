import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';

class RequestDriverService {
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

  //get all available drivers in the map
  static Future<List<Map<String, dynamic>>> fetchAvailableDrivers() async {
    // final logger = Logger();
    DatabaseReference driversRef = FirebaseDatabase.instance.ref('drivers');
    final snapshot =
        await driversRef.orderByChild('status').equalTo('pending').get();

    if (snapshot.exists) {
      return (snapshot.value as Map<dynamic, dynamic>).entries.map((entry) {
        final driverData = entry.value as Map<dynamic, dynamic>;
        final driverCoordinates = driverData['location'];
        return {
          'driverID': entry.key,
          'latitude': driverCoordinates['latitude'],
          'longitude': driverCoordinates['longitude'],
        };
      }).toList();
    }
    return [];
  }

  //Add request data under "drivers/key" node
  static Future<bool> updatePassengerNode(String driverId,
      SharedProvider sharedProvider, String requestType, String nodeName) async {
    final Logger logger = Logger();
    try {
      // Reference to the main node (e.g., a driver ID or any other node ID)
      final DatabaseReference mainNodeRef =
          FirebaseDatabase.instance.ref('drivers/$driverId');

      // Update the "passenger" node under the specific main node
      await mainNodeRef.child(nodeName).set({
        'passengerId': sharedProvider.passengerModel!.id,
        'status': "pending",
        'type': requestType,
        'information': {
          'audioFilePath': '', //In case it is 'byRecordedAudio' type
          'indicationText': '', //In case it is 'byTexting' type
          'name': sharedProvider.passengerModel!.name,
          'phone': sharedProvider.passengerModel!.phone,
          'profilePicture': sharedProvider.passengerModel!.profilePicture,
          'pickUpLocation': sharedProvider.pickUpLocation ?? '',
          'dropOffLocation': sharedProvider.dropOffLocation ?? '',
          "pickUpCoordenates": {
            "latitude": sharedProvider.pickUpCoordenates?.latitude,
            "longitude": sharedProvider.pickUpCoordenates?.longitude,
          },
          "dropOffCoordenates": {
            "latitude": sharedProvider.dropOffCoordenates?.latitude,
            "longitude": sharedProvider.dropOffCoordenates?.longitude,
          },
        },
      });

      logger.i("Passenger node updated successfully.");
      return true;
    } catch (e) {
      logger.e("Error updating passenger node: $e");
      return false;
    }
  }

  //Add passenger to the driver request queue
  static Future<bool> addDriverRequestToQueue(
      SharedProvider sharedProvider) async {
    final logger = Logger();
    try {
      DatabaseReference dataRef =
          FirebaseDatabase.instance.ref('driver_requests');
      Map<String, dynamic> data = {
        'name': sharedProvider.passengerModel!.name,
        'profilePicture': sharedProvider.passengerModel!.profilePicture,
        'pickUpLocation': sharedProvider.pickUpLocation ?? '',
        'dropOffLocation': sharedProvider.dropOffLocation ?? '',
      };

      await dataRef.child(sharedProvider.passengerModel!.id).set(data);
      logger.i("driver request written succesfully.");
      return true;
    } catch (e) {
      logger.e('Error trying to add driverRequest to the queue. : $e');
      return false;
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

      logger.i('Successfully updated driver status for driverId: $driverId');
    } catch (e) {
      logger.e('Failed to update driver status: $e');
    }
  }

  static Future<void> updateDriverStarRatings(double newRating, String driverId,
      String comment, String passengerId) async {
    final Logger logger = Logger();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (driverId.isEmpty) {
      logger.e("Driver Id is empty: $driverId");
      return;
    }

    // Reference to the driver's document
    final DocumentReference userRef =
        firestore.collection('drivers').doc(driverId);

    try {
      // Use Firestore transaction to ensure atomic updates
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          // Retrieve the 'ratings' map or initialize it to default values
          Map<String, dynamic> ratings = userSnapshot.get('ratings') ??
              {
                'totalRatingScore': 0.0,
                'ratingCount': 0,
                'rating': 0.0,
              };

          double totalRatingScore =
              (ratings['totalRatingScore'] ?? 0.0).toDouble();
          int ratingCount = (ratings['ratingCount'] ?? 0).toInt();

          // Update the total rating score and increment the rating count
          totalRatingScore += newRating;
          ratingCount += 1;

          // Calculate the new average rating
          double averageRating = totalRatingScore / ratingCount.toDouble();
          averageRating = double.parse(averageRating.toStringAsFixed(1));

          // Update the 'ratings' map in the driver's document
          transaction.update(userRef, {
            'ratings': {
              'totalRatingScore': totalRatingScore,
              'ratingCount': ratingCount,
              'rating': averageRating,
            }
          });
        } else {
          // Initialize the 'ratings' map if the document doesn't exist
          transaction.set(userRef, {
            'ratings': {
              'totalRatingScore': newRating,
              'ratingCount': 1,
              'rating': newRating,
            }
          });
        }
      });

      logger.i('New rating has been saved and average updated.');

      // If a comment is provided, add it to the subcollection
      if (comment.isNotEmpty) {
        final CollectionReference commentsRef = firestore
            .collection('drivers')
            .doc(driverId)
            .collection('comments');

        await commentsRef.doc(passengerId).set({
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });

        logger.i('Comment has been saved in the subcollection.');
      }
    } catch (e) {
      logger.e("An error occurred while updating ratings: $e");
    }
  }

  //The driver rating is calculated and updated
  // static Future<void> updateDriverStarRatings(
  //     double newRating, String driverId, String comment) async {
  //   final Logger logger = Logger();
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   if (driverId.isEmpty) {
  //     logger.e("Driver Id is empty : $driverId");
  //     return;
  //   }
  //   // Reference to the driver's document
  //   final DocumentReference userRef =
  //       firestore.collection('drivers').doc(driverId);

  //   try {
  //     // Use Firestore transaction to ensure atomic updates
  //     await firestore.runTransaction((transaction) async {
  //       DocumentSnapshot userSnapshot = await transaction.get(userRef);

  //       if (userSnapshot.exists) {
  //         // Retrieve the 'ratings' map or initialize it to default values
  //         Map<String, dynamic> ratings = userSnapshot.get('ratings') ??
  //             {
  //               'totalRatingScore': 0.0,
  //               'ratingCount': 0,
  //               'rating': 0.0,
  //             };

  //         double totalRatingScore =
  //             (ratings['totalRatingScore'] ?? 0.0).toDouble();
  //         int ratingCount = (ratings['ratingCount'] ?? 0).toInt();

  //         // Update the total rating score and increment the rating count
  //         totalRatingScore += newRating;
  //         ratingCount += 1;

  //         // Calculate the new average rating
  //         double averageRating = totalRatingScore / ratingCount.toDouble();
  //         averageRating = double.parse(averageRating.toStringAsFixed(1));

  //         // Update the 'ratings' map in the driver's document
  //         transaction.update(userRef, {
  //           'ratings': {
  //             'totalRatingScore': totalRatingScore,
  //             'ratingCount': ratingCount,
  //             'rating': averageRating,
  //           }
  //         });
  //       } else {
  //         // Initialize the 'ratings' map if the document doesn't exist
  //         transaction.set(userRef, {
  //           'ratings': {
  //             'totalRatingScore': newRating,
  //             'ratingCount': 1,
  //             'rating': newRating,
  //           }
  //         });
  //       }
  //     });

  //     logger.i('New rating has been saved and average updated.');
  //   } catch (e) {
  //     logger.e("An error occurred while updating ratings: $e");
  //   }
  // }
}
