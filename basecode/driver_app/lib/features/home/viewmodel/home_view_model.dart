import 'dart:async';

import 'package:driver_app/features/home/repository/home_realtime_db_service.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as lc;
import 'package:logger/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  Driver? driver;
  final Logger logger = Logger();
  lc.Location location = lc.Location();

  //Permissions
  late StreamSubscription<ServiceStatus> serviceStatusSubscription;
  StreamSubscription<Position>? locationListener;
  bool _locationPermissionsSystemLevel =
      true; //Location services at System level
  bool _locationPermissionUserLevel = false; // Location services at User level
  bool _isCurrentLocationAvailable = true;

  int _currentPageIndex = 0;
  int _deliveryRequestLength = 0;

  //GETTERS
  bool get isCurrentLocationAvailable => _isCurrentLocationAvailable;
  bool get locationPermissionsSystemLevel => _locationPermissionsSystemLevel;
  bool get locationPermissionUserLevel => _locationPermissionUserLevel;
  int get currentPageIndex => _currentPageIndex;
  int get deliveryRequestLength => _deliveryRequestLength;

  //SETTERS

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

  set currentPageIndex(int value) {
    _currentPageIndex = value;
    notifyListeners();
  }

  set deliveryRequestLength(int value) {
    _deliveryRequestLength = value;
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

  // To listen only Delivery request lenght
  void listenToRequests(DatabaseReference requestsRef) {
    requestsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        // Filter pending requests
        List<MapEntry<dynamic, dynamic>> entries = data.entries
            .where((entry) => entry.value['status'] == 'pending')
            .toList();
        deliveryRequestLength = entries.length;
      } else {
        deliveryRequestLength = 0;
      }
    });
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
    // _startLocationTracking(sharedProvider);
    return true;
  }

  // Function to start tracking location changes
  void startLocationTracking(SharedProvider sharedProvider) async {
    isCurrentLocationAvailable = false;
    try {
      // Get the current location
      Position currentPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium)
          .timeout(const Duration(seconds: 5));
      //Update current position in Porvider
      sharedProvider.driverCurrentPosition = currentPosition;
      //Write initial data in realtime database
      await HomeRealtimeDBService.writeOrUpdateLocationInFirebase(
          currentPosition, sharedProvider.driverModel!);
      logger.f("Current location catched: $currentPosition");
      isCurrentLocationAvailable = true;
    } catch (e) {
      logger.e("Error tracking location: $e");
    }
    // Listen for location updates
    locationListener = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 1, // Minimum change (in meters) to trigger updates
      ),
    ).listen((Position position) async {
      // If location is available, update the flag to true
      isCurrentLocationAvailable = true;
      sharedProvider.driverCurrentPosition = position;
      await HomeRealtimeDBService.writeOrUpdateLocationInFirebase(
          position, sharedProvider.driverModel!);
      logger.f(
          "Home View Model Location updated: ${position.latitude}, ${position.longitude}");
    }, onError: (error) {
      // If there is an error, update the flag to false
      isCurrentLocationAvailable = false;
      logger.e("Error getting location: $error");
    });
  }

  Future<bool> requestPermissionsAtUserLevel(
      SharedProvider sharedProvider) async {
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
    // _startLocationTracking(sharedProvider);
    startLocationTracking(sharedProvider);
    return true;
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

  Future<void> setOnDisconnectHandler() async {
    await HomeRealtimeDBService.setOnDisconnectHandler();
  }
}
