import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';
import 'package:location/location.dart' as lc;
import 'package:passenger_app/shared/providers/shared_provider.dart';

class HomeViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  PassengerModel? passenger;
  lc.Location location = lc.Location();
  int _currentPageIndex = 0;
  late StreamSubscription<ServiceStatus> serviceStatusSubscription;
  bool _locationPermissionsSystemLevel =
      true; //Location services at System level
  bool _locationPermissionUserLevel = false; // Location services at User level
  bool _isCurrentLocationAvailable = false;
  Position? currentPosition;

  //Listeners
  StreamSubscription<Position>? positionStream;

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
  //get issue bassed on priority
  Map? getIssueBassedOnPriority() {
    if (!locationPermissionUserLevel) {
      return {
        "priority": 0,
        "color": Colors.red,
        "title": "Permisos de ubicación desactivados.",
        "content": "Click aquí para activarlos",
      };
    }
    if (!locationPermissionsSystemLevel) {
      return {
        "priority": 1,
        "color": Colors.orange,
        "title": "Servicio de ubicación desactivados.",
        "content": "Click aquí para activarlo.",
      };
    }
    if (!isCurrentLocationAvailable) {
      return {
        "priority": 2,
        "color": Colors.white70,
        "title": "Te estamos buscando en el mapa.",
        "content": "Sin señal GPS.",
      };
    }
    return null;
  }

  //Check GPS permissions
  Future<bool> checkGpsPermissions(SharedProvider sharedProvider) async {
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
    //initialize listener
    _startLocationTracking(sharedProvider);
    _getCurrentLocation();

    return true;
  }

  Future<bool> requestPermissionsAtUserLevel(SharedProvider sharedProvider) async {
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
    _startLocationTracking(sharedProvider);
    _getCurrentLocation();
    return true;
  }

  //Open Activate Lcoation Services Dialog
  Future<void> requestLocationServiceSystemLevel() async {
    bool serviceEnabled = await location.requestService();
    locationPermissionsSystemLevel = serviceEnabled;
  }

  /// Listens to changes in location service status
  void listenToLocationServicesAtSystemLevel() {
    serviceStatusSubscription =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      locationPermissionsSystemLevel = (status == ServiceStatus.enabled);
    });
  }

  // Function to start tracking location changes
  void _startLocationTracking(SharedProvider sharedProvider) async {
    //clear listener
    positionStream?.cancel();
    // Listen for location updates
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        //   distanceFilter: 1, // Minimum change (in meters) to trigger updates
      ),
    ).listen((Position position) async {
      // If location is available, update the flag to true
      isCurrentLocationAvailable = true;
      currentPosition = position;
      sharedProvider.passengerCurrentCoords =
          LatLng(position.latitude, position.longitude);
      //  logger.i("Location updated: ${position.latitude}, ${position.longitude}");
    }, onError: (error) {
      // If there is an error, update the flag to false

      isCurrentLocationAvailable = false;

      logger.e("Error getting location: $error");
    });
  }

  void _getCurrentLocation() async {
    try {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      currentPosition = position;
      isCurrentLocationAvailable = true;
      logger.i("GEt currento location executed...");
      //Animate camera
    } catch (e) {
      isCurrentLocationAvailable = false;
      logger.e("Error tracking location: $e");
    }
  }
}
