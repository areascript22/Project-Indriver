import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:passenger_app/features/request_driver/model/ride_location.dart';
import 'package:passenger_app/features/request_driver/repositorie/request_driver_service.dart';
import 'package:passenger_app/shared/widgets/loading_overlay.dart';

class RequestDriverViewModel extends ChangeNotifier {
  //GETTERS

  //SETTERS

  //Request Driver
  void requestTaxi(BuildContext context) async {
    //Display the overlay
    OverlayEntry? overlayEntry;
    final overlay = Overlay.of(context);
    overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);

    User? user = FirebaseAuth.instance.currentUser;
    RideLocation? rideLocation;
    if (user != null) {
      rideLocation = RideLocation(
        clientId: user.uid,
        pickUpCoordinates: "",
        dropOffCoordinates: "",
        pickUpLocation: "",
        destinationLocation: "",
        destinationReference: "",
        status: "pending",
        distance: "",
        duration: "",
      );
    }

    //GEt First Driver in Queue
    String? firstDriverKey =
        await RequestDriverService.getFirstDriverKeyOrderedByTimestamp();
    Map<String, dynamic>? driverInfo;
    if (firstDriverKey != null) {
      driverInfo =
          await RequestDriverService.getDriverInformationById(firstDriverKey);
    }
    if (driverInfo != null) {
      await RequestDriverService.updatePassengerNode(
          firstDriverKey!, rideLocation!);
    }

    //Remove overlay when it's all comleted
    overlayEntry.remove();
    overlayEntry = null;
  }
}
