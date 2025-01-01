import 'package:driver_app/features/auth/repository/firestore_service.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  Driver? driverModel;
  bool _loading = false;

  //GETTERS
  bool get loading => _loading;

  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  //Functions
  Future<Object> getAuthenticatedDriver() async {
    return FirestoreService.getAuthenticatedDriver();
  }
}
