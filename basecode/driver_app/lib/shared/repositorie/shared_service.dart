import 'dart:async';
import 'dart:io';
import 'package:driver_app/shared/models/route_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

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

  // Sign out
  static Future<void> signOut() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }
}
