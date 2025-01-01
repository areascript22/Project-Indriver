import 'package:driver_app/shared/models/driver.dart';
import 'package:flutter/material.dart';

class SharedProvider extends ChangeNotifier {
  Driver? driverModel; //To user PassengerModel data across multiple Features
  bool isGPSPermissionsEnabled = false;

  //GETTERS
  // bool get isGPSPermissionsEnabled => _isGPSPermissionsEnabled;

  //SETTERS
  // set isGPSPermissionsEnabled(bool value) {
  //   _isGPSPermissionsEnabled = value;
  //   notifyListeners();
  // }

  // PassengerModel? get passengerModel => _passengerModel;

  // set passengerModel(PassengerModel? value) {
  //   _passengerModel = value;
  //   notifyListeners();
  // }

  //GETTERS
  //SETTERS
}
