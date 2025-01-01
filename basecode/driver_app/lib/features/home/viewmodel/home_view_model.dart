import 'dart:async';

import 'package:driver_app/features/home/repository/home_realtime_db_service.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as lc;
import 'package:logger/logger.dart';

class HomeViewModel extends ChangeNotifier {
  Driver? driver;
  final Logger logger = Logger();
  lc.Location location = lc.Location();
  int _currentPageIndex = 0;
  late StreamSubscription<ServiceStatus> serviceStatusSubscription;
  bool _locationPermissionsSystemLevel =
      true; //Location services at System level
  bool _locationPermissionUserLevel = false; // Location services at User level
  bool _isCurrentLocationAvailable = false;

  //GETTERS
  int get currentPageIndex => _currentPageIndex;
  bool get locationPermissionsSystemLevel => _locationPermissionsSystemLevel;
  bool get locationPermissionUserLevel => _locationPermissionUserLevel;
  bool get isCurrentLocationAvailable => _isCurrentLocationAvailable;

  //SETTERS
  set currentPageIndex(int value) {
    _currentPageIndex = value;
    notifyListeners();
  }

  set locationPermissionsSystemLevel(bool value) {
    _locationPermissionsSystemLevel = value;
    notifyListeners();
  }

  set locationPermissionUserLevel(bool value) {
    _locationPermissionUserLevel = value;
    notifyListeners();
  }

  set isCurrentLocationAvailable(bool value) {
    _isCurrentLocationAvailable = value;
    notifyListeners();
  }

  //FUNCTIONS

  //Check GPS permissions
  Future<bool> checkGpsPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      locationPermissionsSystemLevel = false;
      return false;
    }

    // Check the app's location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // App does not have location permissions
      locationPermissionUserLevel = false;
      return false;
    }

    // Location services are enabled and app has permissions
    locationPermissionUserLevel = true;
    return true;
  }

  Future<bool> requestPermissionsAtUserLevel() async {
    // Check the app's location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permissions
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied
        locationPermissionUserLevel = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, cannot request them
      try {
        await Geolocator.openAppSettings();
        // After opening settings, you can't recheck immediately
      } on PlatformException catch (e) {
        logger.i("Error opening app settings: $e");
        locationPermissionUserLevel = false;
        return false;
      }
      locationPermissionUserLevel = false;
      return false;
    }

    // If all checks pass, permissions are granted and location services are enabled
    locationPermissionUserLevel = true;
    return true;
  }

  // Function to start tracking location changes
  void startLocationTracking() async {
    try {
      // Get the current location
      Position currentPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium)
          .timeout(const Duration(seconds: 5));
      await HomeRealtimeDBService.updateLocationInFirebase(currentPosition,driver!);
    } catch (e) {
      logger.e("Error tracking location: $e");
    }

    // Listen for location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 1, // Minimum change (in meters) to trigger updates
      ),
    ).listen((Position position) async {
      // If location is available, update the flag to true
      isCurrentLocationAvailable = true;
      await HomeRealtimeDBService.updateLocationInFirebase(position,driver!);
      logger.i("Location updated: ${position.latitude}, ${position.longitude}");
    }, onError: (error) {
      // If there is an error, update the flag to false

      isCurrentLocationAvailable = false;

      logger.e("Error getting location: $error");
    });
  }

  /// Listens to changes in location service status
  void listenToLocationServicesAtSystemLevel() {
    serviceStatusSubscription =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      locationPermissionsSystemLevel = (status == ServiceStatus.enabled);
    });
  }

  //Open Activate Lcoation Services Dialog
  Future<void> requestLocationServiceSystemLevel() async {
    bool serviceEnabled = await location.requestService();
    locationPermissionsSystemLevel = serviceEnabled;
  }

  //Set on disconnect handler
  Future<void> setonDisconnectHandler() async {
    return await HomeRealtimeDBService.setOnDisconnectHandler();
  }
}