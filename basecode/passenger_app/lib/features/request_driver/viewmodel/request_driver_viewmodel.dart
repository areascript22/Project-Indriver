import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/core/utils/toast_message_util.dart';
import 'package:passenger_app/features/request_driver/repositorie/request_driver_service.dart';
import 'package:passenger_app/features/request_driver/view/widgets/driver_arrived_bottom_sheet.dart';
import 'package:passenger_app/features/request_driver/view/widgets/star_ratings_bottom_sheet.dart';
import 'package:passenger_app/shared/models/driver_model.dart';
import 'package:passenger_app/shared/models/route_info.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/repositories/shared_service.dart';
import 'package:passenger_app/shared/widgets/loading_overlay.dart';

class RequestDriverViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  //listeners
  StreamSubscription<DatabaseEvent>? driverStatusListener;
  StreamSubscription<DatabaseEvent>? driverPositionListener;

  //GETTERS

  //SETTERS

  //Cancel listeners
  void cancelDriverListeners() {
    driverStatusListener?.cancel();
    driverPositionListener?.cancel();
  }

  //Request Driver
  void requestTaxi(BuildContext context, SharedProvider sharedProvider,
      String requestType) async {
    //Display the overlay
    OverlayEntry? overlayEntry;
    final overlay = Overlay.of(context);
    overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      logger.e("Error, user not authenticated");
      overlayEntry.remove();
      return;
    }

    //GEt First Driver in Queue
    String? firstDriverKey =
        await RequestDriverService.getFirstDriverKeyOrderedByTimestamp();

    DriverModel? driverInfo;
    bool passengerNodeUpdated = false;
    if (firstDriverKey != null) {
      //There are drivers in queue
      driverInfo = await SharedService.getDriverInformationById(firstDriverKey);
      passengerNodeUpdated = await RequestDriverService.updatePassengerNode(
          firstDriverKey, sharedProvider, requestType, 'passenger');
    } else {
      //There are not any drivers in Queue
      Map<String, dynamic>? nearestDriver =
          await _findNearestDriver(sharedProvider.passengerCurrentCoords!);
      if (nearestDriver != null) {
        //We find a driver available in the map
        String nearestDriverId = nearestDriver['driverID'];
        driverInfo =
            await SharedService.getDriverInformationById(nearestDriverId);
        passengerNodeUpdated = await RequestDriverService.updatePassengerNode(
            nearestDriverId, sharedProvider, requestType, 'passenger');
      } else {
        //There is not driver available in the map
        //Pass to Reqeusts queue
        await addDriverRequestToQueue(sharedProvider, requestType);
      }

      ToastMessageUtil.showToast("Sin vehículos disponibles.");
    }

    //Move to Operation mode
    if (passengerNodeUpdated && driverInfo != null) {
      sharedProvider.driverModel = driverInfo;
      _listenToDriverStatus(driverInfo.id, sharedProvider);
      _listenToDriverCoordenates(driverInfo.id, sharedProvider);
    }
    //Remove overlay when it's all comleted
    overlayEntry.remove();
  }

  //Add driver requuest to queue: Only if There aren't vehicles available
  Future<void> addDriverRequestToQueue(
      SharedProvider sharedProvider, String requestType) async {
    bool driverRequestSuccess =
        await RequestDriverService.addDriverRequestToQueue(sharedProvider);
    if (!driverRequestSuccess) {
      return;
    }
    sharedProvider.deliveryLookingForDriver = true;
    //Listen to driver
    final databaseRef = FirebaseDatabase.instance
        .ref('driver_requests/${sharedProvider.passengerModel!.id}/driver');
    databaseRef.onValue.listen((event) async {
      if (event.snapshot.exists) {
        String? driverId = event.snapshot.value as String?;
        if (driverId == null) {
          return;
        }
        logger.i("A driver has accepted us request. $driverId");
        sharedProvider.deliveryLookingForDriver = false;
        //ASUMING THERE IS A DRIVER
        DriverModel? driverInfo =
            await SharedService.getDriverInformationById(driverId);
        bool passengerNodeUpdated =
            await RequestDriverService.updatePassengerNode(
                driverId, sharedProvider, requestType, 'secondPassenger');
        //Move to Operation mode
        if (passengerNodeUpdated && driverInfo != null) {
          sharedProvider.driverModel = driverInfo;
          //    _listenToDriverStatus(driverInfo.id, sharedProvider);
          //  _listenToDriverCoordenates(driverInfo.id, sharedProvider);
        }
      }
    });
  }

  //get the nearest driver
  Future<Map<String, dynamic>?> _findNearestDriver(LatLng userLocation) async {
    final drivers = await RequestDriverService.fetchAvailableDrivers();
    if (drivers.isEmpty) return null;

    Map<String, dynamic>? nearestDriver;
    double minDistance = double.infinity;

    for (var driver in drivers) {
      double distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        driver['latitude'],
        driver['longitude'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestDriver = driver;
      }
    }

    return nearestDriver;
  }

//HELPER: To calculate the distance between two coordinates
  double _calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(
        startLat, startLng, endLat, endLng); // Distance in meters
  }

  //LISTENER: To update TaxiMarker based on driver coordinates
  void _listenToDriverCoordenates(
      String driverId, SharedProvider sharedProvider) {
    Logger logger = Logger();
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/location');

    try {
      driverPositionListener = databaseRef.onValue.listen((event) async {
        //Check if there is any data
        if (event.snapshot.exists) {
          //get coordinates
          final coords = event.snapshot.value as Map;
          final LatLng driverCoords = LatLng(
              coords['latitude'].toDouble(), coords['longitude'].toDouble());

          //Update Driver marker
          sharedProvider.driverMarker = Marker(
              markerId: const MarkerId("marker_id"),
              icon: sharedProvider.driverIcon ?? BitmapDescriptor.defaultMarker,
              position: driverCoords);
          //Update Polyline (Route from Driver to pick up point)
          LatLng destination = sharedProvider.pickUpCoordenates!;
          if (sharedProvider.driverStatus == DriverRideStatus.goingToDropOff) {
            destination = sharedProvider.dropOffCoordenates!;
          }

          RouteInfo? routeInfo = await SharedService.getRoutePolylinePoints(
              driverCoords, destination, apiKey);

          if (routeInfo != null) {
            sharedProvider.polylineFromPickUpToDropOff = Polyline(
              polylineId: const PolylineId("pickUpToDropoff"),
              points: routeInfo.polylinePoints,
              width: 5,
              color: Colors.blue,
            );
          }
        }
      });
    } catch (e) {
      logger.e('Error listening to driver coordinates: $e');
    }
  }

  //LISTENER: To listen every status of the driver
  void _listenToDriverStatus(String driverId, SharedProvider sharedProvider) {
    final Logger logger = Logger();
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/status');

    try {
      driverStatusListener = databaseRef.onValue.listen((DatabaseEvent event) {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          // Get the status value
          final status = event.snapshot.value as String;
          logger.i("Driver Status changed to: ${status}");
          switch (status) {
            case DriverRideStatus.goingToPickUp:
              sharedProvider.driverStatus = DriverRideStatus.goingToPickUp;
              break;
            case DriverRideStatus.arrived:
              sharedProvider.driverStatus = DriverRideStatus.arrived;
              //Show Bottom Sheet
              if (sharedProvider.mapPageContext != null) {
                showDriverArrivedBotttomSheet(sharedProvider.mapPageContext!);
              }
              break;
            case DriverRideStatus.goingToDropOff:
              sharedProvider.driverStatus = DriverRideStatus.goingToDropOff;
              break;
            case DriverRideStatus.finished:
              sharedProvider.driverStatus = DriverRideStatus.finished;
              //Rate the driver
              showStarRatingsBottomSheet(sharedProvider.mapPageContext!,
                  sharedProvider.driverModel!.id);
              //Return to normal state of the appp
              sharedProvider.driverModel = null;
              sharedProvider.dropOffCoordenates = null;
              sharedProvider.dropOffLocation = null;
              sharedProvider.pickUpCoordenates = null;
              sharedProvider.pickUpLocation = null;
              sharedProvider.selectingPickUpOrDropOff = true;
              sharedProvider.duration = null;
              sharedProvider.markers.clear();
              sharedProvider.polylineFromPickUpToDropOff.points.clear();
              cancelDriverListeners();

              break;
            default:
              logger.e("Driver Status not found..");
              break;
          }
        } else {
          logger.i('Driver $driverId status does not exist.');
        }
      });
    } catch (e) {
      logger.e('Error listening to driver status: $e');
    }
  }

  //CALLED BY DriverArrivedBottomSheet widget
  void updateDriverStatus(
      String driverId, String status, BuildContext context) async {
    //
    //Display the overlay

    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);

    //Update Driver Status
    await RequestDriverService.updateDriverStatus(driverId, status);
    //Remove overlay when it's all comleted
    overlayEntry.remove();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void updateDriverStarRatings(double newRating, String driverId,
      BuildContext context, String comment) async {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);
    //Update star
    final passengerId = FirebaseAuth.instance.currentUser?.uid;
    if (passengerId != null) {
      await RequestDriverService.updateDriverStarRatings(
        newRating,
        driverId,
        comment,
        passengerId,
      );
    } else {
      logger.e("Error, usuario no autenticado");
    }

    overlayEntry.remove();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
