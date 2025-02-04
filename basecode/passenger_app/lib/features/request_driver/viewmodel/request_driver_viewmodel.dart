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
import 'package:passenger_app/shared/models/request_type.dart';
import 'package:passenger_app/shared/models/route_info.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/repositories/shared_service.dart';
import 'package:passenger_app/shared/util/shared_util.dart';
import 'package:passenger_app/shared/widgets/loading_overlay.dart';

class RequestDriverViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final SharedUtil sharedUtil = SharedUtil();
  //listeners
  StreamSubscription<DatabaseEvent>? driverStatusListener;
  StreamSubscription<DatabaseEvent>? driverPositionListener;
  StreamSubscription<DatabaseEvent>? passengerIdChangesListener;

  //GETTERS

  //SETTERS

  //Cancel listeners
  void cancelDriverListeners() {
    driverStatusListener?.cancel();
    driverPositionListener?.cancel();
    passengerIdChangesListener?.cancel();
  }

  //Request Driver
  void requestTaxi(
    BuildContext context,
    SharedProvider sharedProvider,
    String requestType, {
    String? audioFilePath,
    String? indicationText,
  }) async {
    //Display the overlay
    OverlayEntry? overlayEntry;
    final overlay = Overlay.of(context);
    overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);
    ////
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
        firstDriverKey,
        sharedProvider,
        requestType,
        'passenger',
        audioFilePath: audioFilePath,
        indicationText: indicationText,
      );
    }

    if (firstDriverKey == null) {
      //There are not any drivers in Queue
      if (sharedProvider.passengerCurrentCoords == null) {
        ToastMessageUtil.showToast("Sin señal gps. Muevete a un mejor lugar.");
        overlayEntry.remove();
        return;
      }
      Map<String, dynamic>? nearestDriver =
          await _findNearestDriver(sharedProvider.passengerCurrentCoords!);
      if (nearestDriver != null) {
        //We find a driver available in the map
        logger.f("debugging: Nearest driver ID");
        String nearestDriverId = nearestDriver['driverID'];
        driverInfo =
            await SharedService.getDriverInformationById(nearestDriverId);
        passengerNodeUpdated = await RequestDriverService.updatePassengerNode(
          nearestDriverId,
          sharedProvider,
          requestType,
          'passenger',
          audioFilePath: audioFilePath,
          indicationText: indicationText,
        );
      } else {
        //There is not driver available in the map
        //Pass to Reqeusts queue
        await addDriverRequestToQueue(
          sharedProvider,
          requestType,
          audioFilePath: audioFilePath,
          indicationText: indicationText,
        );
      }
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
    SharedProvider sharedProvider,
    String requestType, {
    String? audioFilePath,
    String? indicationText,
  }) async {
    bool driverRequestSuccess =
        await RequestDriverService.addDriverRequestToQueue(sharedProvider);
    if (!driverRequestSuccess) {
      return;
    }
    sharedProvider.deliveryLookingForDriver = true;
    // showWaitingForDriverOverlay(sharedProvider.mapPageContext!, () {
    //   Navigator.pop(sharedProvider.mapPageContext!);
    // });
    //Listen to driver
    final databaseRef = FirebaseDatabase.instance
        .ref('driver_requests/${sharedProvider.passenger!.id}/driver');
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
          driverId,
          sharedProvider,
          requestType,
          'secondPassenger',
          audioFilePath: audioFilePath,
          indicationText: indicationText,
        );
        //Move to Operation mode
        if (passengerNodeUpdated && driverInfo != null) {
          sharedProvider.driverModel = driverInfo;
          //    _listenToDriverStatus(driverInfo.id, sharedProvider);
          _listenToDriverCoordenates(driverInfo.id, sharedProvider);
          _listenToPassengerIdChanges(
              driverId, sharedProvider.passenger!.id!, sharedProvider);
        }
      }
    });
  }

  //Listen when Our request pass to be the Current ride
  void _listenToPassengerIdChanges(
      String driverId, String passengerId, SharedProvider sharedProvider) {
    final databaseRef = FirebaseDatabase.instance.ref();

    // Define the path to listen for passengerId changes
    final passengerIdPath =
        databaseRef.child('drivers/$driverId/passenger/passengerId');

    passengerIdChangesListener =
        passengerIdPath.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        String passengerIdTemp = event.snapshot.value.toString();

        // Check if the passengerId matches "123456"
        if (passengerIdTemp == passengerId) {
          logger.i("Pasenger id : $passengerIdTemp  our id; $passengerId");
          _listenToDriverStatus(driverId, sharedProvider);
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
          //Check if it is necesary to draw route
          if (sharedProvider.pickUpCoordenates == null ||
              sharedProvider.dropOffCoordenates == null ||
              sharedProvider.requestType != RequestType.byCoordinates) {
            return;
          }
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
      driverStatusListener =
          databaseRef.onValue.listen((DatabaseEvent event) async {
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
              //   await sharedUtil.playAudio("sounds/taxi_espera.mp3");
              sharedUtil.repeatAudio("sounds/taxi_espera.mp3");
              break;
            case DriverRideStatus.goingToDropOff:
              sharedProvider.driverStatus = DriverRideStatus.goingToDropOff;
              sharedUtil.stopAudioLoop();
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

              sharedProvider.polylineFromPickUpToDropOff =
                  const Polyline(polylineId: PolylineId("default"));

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

  //Upload recorded audio to Firestore Storage
  Future<String?> uploadRecordedAudioToStorage(
      String audioFilePath, BuildContext context) async {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);
    ////
    final passengerId = FirebaseAuth.instance.currentUser?.uid;
    if (passengerId == null) {
      logger.e("Error: Passenger is not authenticated.");
      return null;
    }
    String? response =
        await SharedService.uploadAudioToFirebase(audioFilePath, passengerId);
    overlayEntry.remove();
    return response;
  }
}
