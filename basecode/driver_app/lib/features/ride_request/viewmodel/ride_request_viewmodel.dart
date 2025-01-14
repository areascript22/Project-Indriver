import 'dart:async';

import 'package:driver_app/features/ride_request/repository/ride_request_service.dart';
import 'package:driver_app/features/ride_request/view/widgets/bottom_sheeet_star_ratings.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:driver_app/shared/models/route_info.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/shared_service.dart';
import 'package:driver_app/shared/widgets/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

class RideRequestViewModel extends ChangeNotifier {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final Logger logger = Logger();
  final RideRequestService realtimeDBService = RideRequestService();
  BuildContext? rideRequestPageContext;
  //For map
  Completer<GoogleMapController> mapController = Completer();
  Polyline _polylineFromPickUpToDropOff =
      const Polyline(polylineId: PolylineId("default"));
  Set<Marker> _markers = {};
  PassengerInformation? _passengerInformation;
  String _driverRideStatus = '';

  //For Driver Queue Positions
  bool _driverInQueue = false;
  int? _currenQueuePoosition;
  int? myPosition;

  //for listeners
  StreamSubscription<DatabaseEvent>? driverPositionListener;
  StreamSubscription<DatabaseEvent>? passengerRequestListener;
  StreamSubscription<DatabaseEvent>? driverStatusListener;

  //GETTERS
  bool get driverInQueue => _driverInQueue;
  int? get currenQueuePoosition => _currenQueuePoosition;
  Polyline get polylineFromPickUpToDropOff => _polylineFromPickUpToDropOff;
  Set<Marker> get markers => _markers;
  PassengerInformation? get passengerInformation => _passengerInformation;
  String get driverRideStatus => _driverRideStatus;

  //SETTERS
  set driverInQueue(bool value) {
    _driverInQueue = value;
    notifyListeners();
  }

  set currenQueuePoosition(int? value) {
    _currenQueuePoosition = value;
    notifyListeners();
  }

  set polylineFromPickUpToDropOff(Polyline value) {
    _polylineFromPickUpToDropOff = value;
    notifyListeners();
  }

  set markers(Set<Marker> value) {
    _markers = value;
    notifyListeners();
  }

  set passengerInformation(PassengerInformation? value) {
    _passengerInformation = value;
    notifyListeners();
  }

  set driverRideStatus(String value) {
    _driverRideStatus = value;
    notifyListeners();
  }

  void cancelListeners() {
    driverPositionListener?.cancel();
    passengerRequestListener?.cancel();
    driverStatusListener?.cancel();
  }

  //FUNCTIONS
  //On map created
  void onMapCreated(
      GoogleMapController controller, SharedProvider sharedProvider) async {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  //LISTENER: To Redraw route when there is passenger info
  void listenToDriverCoordenatesInFirebase(SharedProvider sharedProvider) {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/location');

    try {
      driverPositionListener = databaseRef.onValue.listen((event) async {
        //Check if there is any data
        if (event.snapshot.exists) {
          if (passengerInformation != null) {
            //get coordinates
            final coords = event.snapshot.value as Map;
            final LatLng driverCoords = LatLng(
                coords['latitude'].toDouble(), coords['longitude'].toDouble());
            //Draw Polyline
            LatLng destination = passengerInformation!.dropOffCoordinates;
            if (driverRideStatus == DriverRideStatus.goingToPickUp) {
              destination = passengerInformation!.pickUpCoordinates;
            }
            RouteInfo? routeInfo = await SharedService.getRoutePolylinePoints(
                driverCoords, destination, apiKey);
            if (routeInfo != null) {
              polylineFromPickUpToDropOff = Polyline(
                polylineId: const PolylineId(""),
                points: routeInfo.polylinePoints,
                color: Colors.blue,
                width: 5,
              );
            }
          }
        }
      });
    } catch (e) {
      logger.e('Error listening to driver coordinates: $e');
    }
  }

  //LISTENER: To listen when a Passenger request Us
  void listenerToPassengerRequest(SharedProvider sharedProvider) {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }

    final databaseRef = FirebaseDatabase.instance
        .ref('drivers/$driverId/passenger/information');

    try {
      passengerRequestListener =
          databaseRef.onValue.listen((DatabaseEvent event) {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          try {
            // Get the status value
            final passangerInfo = event.snapshot.value as Map;
            final PassengerInformation tempPassengerInformation =
                PassengerInformation.fromMap(passangerInfo);

            //Update passenger information
            passengerInformation = tempPassengerInformation;
            //Update Driver ride status
            driverRideStatus = DriverRideStatus.goingToPickUp;
            //Add markers
            markers.add(
              Marker(
                markerId: const MarkerId("pick_up"),
                position: tempPassengerInformation.pickUpCoordinates,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
            );
            markers.add(
              Marker(
                markerId: const MarkerId("drop_off"),
                position: tempPassengerInformation.dropOffCoordinates,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
            );
            //Free up driver position in Queue
            freeUpDriverPositionInQueue();
          } catch (e) {
            logger.e("Error trying ti get data : $e");
            passengerInformation = null;
          }
        } else {
          passengerInformation = null;
        }
      });
    } catch (e) {
      logger.e('Error listening passenger request: $e');
    }
  }

  //LISTENER: to lsiten value changes under 'drivers/driverId/status'
  void listenToDriverStatus(SharedProvider sharedProvider) {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/status');

    try {
      driverStatusListener =
          databaseRef.onValue.listen((DatabaseEvent event) async {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          // Get the status value
          final status = event.snapshot.value as String;
          switch (status) {
            case DriverRideStatus.goingToPickUp:
              driverRideStatus = DriverRideStatus.goingToPickUp;
              break;
            case DriverRideStatus.arrived:
              driverRideStatus = DriverRideStatus.arrived;
              break;
            case DriverRideStatus.goingToDropOff:
              driverRideStatus = DriverRideStatus.goingToDropOff;
              break;
            case DriverRideStatus.finished:
              driverRideStatus = DriverRideStatus.finished;
              if (rideRequestPageContext != null) {
                showRideStarRatingsBottomSheet(
                    rideRequestPageContext!, driverId);
              }
              markers.clear();
              polylineFromPickUpToDropOff =
                  const Polyline(polylineId: PolylineId("default"));
              await RideRequestService.removePassengerInfo();

              break;
            case DriverRideStatus.pending:
              driverRideStatus = DriverRideStatus.pending;
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

  //Update 'status' field under 'drivers/driverID/status'
  Future<void> updateDriverStatus(String status) async {
    BuildContext context = rideRequestPageContext!;
    //Display the overlay
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);
    //get driver id
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
    } else {
      //Update Driver Status
      await RideRequestService.updateDriverStatus(driverId, status);
    }
    overlayEntry.remove();
  }

  //Remove driver position in Queue in realtime database
  void freeUpDriverPositionInQueue() async {
    await RideRequestService.freeUpDriverPositionInQueue();
    driverInQueue = false;
    currenQueuePoosition = null;
    myPosition = null;
  }
}
