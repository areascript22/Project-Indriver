import 'dart:async';

import 'package:driver_app/features/home/repository/home_realtime_db_service.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/shared_service.dart';
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
  bool _loading = false;

  //LISTENERS
  StreamSubscription<ServiceStatus>? locationServicesAtSystemLevelListener;
  StreamSubscription<Position>? locationListener;
  StreamSubscription<DatabaseEvent>? deliveryRequestLitener;
  StreamSubscription<DatabaseEvent>? pendingRequestsLitener;

  bool _locationPermissionsSystemLevel =
      true; //Location services at System level
  bool _locationPermissionUserLevel = false; // Location services at User level
  bool _isCurrentLocationAvailable = true;

  int _currentPageIndex = 0;
  int _deliveryRequestLength = 0;
  int _pendingRequestLength = 0;

  //GETTERS
  bool get loading => _loading;
  bool get isCurrentLocationAvailable => _isCurrentLocationAvailable;
  bool get locationPermissionsSystemLevel => _locationPermissionsSystemLevel;
  bool get locationPermissionUserLevel => _locationPermissionUserLevel;
  int get currentPageIndex => _currentPageIndex;
  int get deliveryRequestLength => _deliveryRequestLength;
  int get pendingRequestLength => _pendingRequestLength;

  //SETTERS
  set loading(bool value) {
    _loading = value;
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

  set currentPageIndex(int value) {
    _currentPageIndex = value;
    notifyListeners();
  }

  set deliveryRequestLength(int value) {
    _deliveryRequestLength = value;
    notifyListeners();
  }

  set pendingRequestLength(int value) {
    _pendingRequestLength = value;
    notifyListeners();
  }

  //FUNCTIONS
  void clearListeners() {
    locationServicesAtSystemLevelListener?.cancel();
    locationListener?.cancel();
    deliveryRequestLitener?.cancel();
  }

  //Sign out
  Future<void> signOut() async {
    loading = true;
    await SharedService.signOut();
    loading = false;
  }

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
  void listenToDeliveryRequests(DatabaseReference requestsRef) {
    deliveryRequestLitener = requestsRef.onValue.listen((event) {
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

  // To listen only pending ride request lenght
  void listenToPendingRideRequests(DatabaseReference requestsRef) {
    deliveryRequestLitener = requestsRef.onValue.listen((event) {
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
    startLocationTracking(sharedProvider);
    return true;
  }

  // Function to start tracking location changes
  void startLocationTracking(SharedProvider sharedProvider) async {
    locationListener?.cancel();
    isCurrentLocationAvailable = false;
    try {
      // Get the current location
      Position currentPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low)
          .timeout(const Duration(seconds: 5));
      //Update current position in Porvider
      sharedProvider.driverCurrentPosition = currentPosition;
      //Write initial data in realtime database
      await HomeRealtimeDBService.writeOrUpdateLocationInFirebase(
          currentPosition, sharedProvider.driverModel!);
      logger.f("Current location catched : $currentPosition");
      isCurrentLocationAvailable = true;
    } catch (e) {
      logger.e("Error tryng to Catch current location: $e");
    }
    //Get last known position
    if (!isCurrentLocationAvailable) {
      Position? cPosition = await Geolocator.getLastKnownPosition();
      if (cPosition != null) {
        logger.f("Last known position Catched");
        sharedProvider.driverCurrentPosition = cPosition;
        isCurrentLocationAvailable = true;
        await HomeRealtimeDBService.writeOrUpdateLocationInFirebase(
            cPosition, sharedProvider.driverModel!);
      }
    }
    // Listen for location updates
    locationListener = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,

        // distanceFilter: 1, // Minimum change (in meters) to trigger updates
      ),
    ).listen((Position position) async {
      // If location is available, update the flag to true
      isCurrentLocationAvailable = true;
      sharedProvider.driverCurrentPosition = position;
      await HomeRealtimeDBService.writeOrUpdateLocationInFirebase(
          position, sharedProvider.driverModel!);
      logger.f(
          "Listener Location updated: ${position.latitude}, ${position.longitude}");
    }, onError: (error) {
      // If there is an error, update the flag to false
      isCurrentLocationAvailable = false;
      logger.e("Error Loistening location: $error");
    });
  }

  //request permissions
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
    locationServicesAtSystemLevelListener =
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
