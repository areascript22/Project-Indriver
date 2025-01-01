import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class TestPage extends StatefulWidget {
  const TestPage();
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  bool isLocationAvailable = false; // Flag to track location availability
  String value = '';
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _startLocationTracking(); // Start location tracking when the app runs
  }

  // Function to start tracking location changes
  void _startLocationTracking() {
    // Listen for location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Minimum change (in meters) to trigger updates
      ),
    ).listen((Position position) {
      // If location is available, update the flag to true
      setState(() {
        isLocationAvailable = true;
        value = "Location updated: ${position.latitude}, ${position.longitude}";
      });
      logger.i("Location updated: ${position.latitude}, ${position.longitude}");
    }, onError: (error) {
      // If there is an error, update the flag to false
      setState(() {
        isLocationAvailable = false;
      });
      logger.e("Error getting location: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Tracker")),
      body: Center(
        child: isLocationAvailable
            ? Text(
                "Location is available $value",
                style: TextStyle(color: Colors.green, fontSize: 18),
              )
            : Text(
                "Location is unavailable $value",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
      ),
    );
  }
}
