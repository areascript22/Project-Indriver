import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/driver_model.dart';
import 'package:passenger_app/shared/models/route_info.dart';

class SharedService {
  //It returns a route as polylines (it is use to update polyline in Porvider)
  static Future<RouteInfo?> getRoutePolylinePoints(
      LatLng start, LatLng end, String apiKey) async {
    final Logger logger = Logger();

    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> routePoints = [];
    try {
      try {
        PolylineResult result = await polylinePoints
            .getRouteBetweenCoordinates(
              googleApiKey: apiKey,
              request: PolylineRequest(
                  origin: PointLatLng(start.latitude, start.longitude),
                  destination: PointLatLng(end.latitude, end.longitude),
                  mode: TravelMode.driving),
            )
            .timeout(const Duration(seconds: 10));
        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            routePoints.add(LatLng(point.latitude, point.longitude));
          });
        }
        logger.i(
            "Result getting route: ${result.durationTexts} type: ${result.durationTexts![0]}");
        return RouteInfo(
          distance: "",
          duration:
              result.durationTexts != null ? result.durationTexts![0] : "",
          polylinePoints: routePoints,
        );
      } on TimeoutException catch (e) {
        logger.e("Timeout occurred: $e");
        return null;
      } on SocketException catch (e) {
        logger.e("Network issue: $e");
        return null;
      } catch (e) {
        logger.e("Unknown error: $e");
        return null;
      }
    } catch (e) {
      logger.e('Error fetching route: $e');
      return null;
    }
  }

  //Get driver data by id, under "drivers" node
  static Future<DriverModel?> getDriverInformationById(String driverId) async {
    final Logger logger = Logger();
    try {
      final DatabaseReference driversRef =
          FirebaseDatabase.instance.ref('drivers');
      final DataSnapshot snapshot =
          await driversRef.child('$driverId/information').get();

      if (snapshot.exists && snapshot.value != null) {
        return DriverModel.fromFirestore(snapshot, driverId);
      } else {
        logger.e("No data found for driver ID: $driverId ");
        return null;
      }
    } catch (e) {
      logger.e("Error fetching driver data: $e, ");
      return null;
    }
  }

  //Upload an audio file to Storage and get its URL
  static Future<String?> uploadAudioToFirebase(String filePath) async {
    final logger = Logger();
    final passengerId = FirebaseAuth.instance.currentUser?.uid;
    if (passengerId == null) {
      logger.e("The passenger is not autenticated.");
      return null;
    }
    try {
      final firebaseStorage = FirebaseStorage.instance;
      final fileName = '$passengerId.aac';
      final storageRef =
          firebaseStorage.ref().child('audio_requests/$fileName');
      final uploadTask = await storageRef.putFile(File(filePath));
      final downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      // Handle any errors that occur during upload
      logger.e('Failed to upload audio: $e');
      return null;
    }
  }
}
