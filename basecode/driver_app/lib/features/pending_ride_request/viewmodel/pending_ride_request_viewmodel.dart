import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/pending_ride_request/repository/pending_ride_request_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PendingRideRequestViewModel extends ChangeNotifier {
  final logger = Logger();
  bool _loading = false;

  //GETTERS
  bool get loading => _loading;
  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  //LOGIC
  Future<void> addDriverToRideRequest(String passengerId) async {
    loading = true;
    //get driver Id
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Driver is not authenticated.");
      return;
    }
    bool response = await PendingRideRequestService.addDriverToRideRequest(
        passengerId, driverId);
    if (response) {
      //Pending
      await PendingRideRequestService.removeRideRequest(passengerId);
    } else {
      ToastMessageUtil.showToast("Peticion expirada");
    }
    loading = false;
  }
}
