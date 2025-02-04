import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/features/ride_request/repository/ride_request_service.dart';
import 'package:driver_app/features/ride_request/utils/ride_history_util.dart';
import 'package:driver_app/features/ride_request/view/widgets/bottom_sheeet_star_ratings.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:driver_app/shared/models/passenger_request.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:driver_app/shared/models/route_info.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/shared_service.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

class RideRequestViewModel extends ChangeNotifier {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final Logger logger = Logger();
  final RideRequestService realtimeDBService = RideRequestService();
  final SharedUtil sharedUtil = SharedUtil();
  BuildContext? rideRequestPageContext;
  //For map
  Completer<GoogleMapController> mapController = Completer();
  Polyline _polylineFromPickUpToDropOff =
      const Polyline(polylineId: PolylineId("default"));
  Set<Marker> _markers = {};
  PassengerInformation? _passengerInformation;
  String? passengerId;
  PassengerRequest? _secondPassenger;
  String _driverRideStatus = '';

  //For Driver Queue Positions
  bool _driverInQueue = false;
  int? _currenQueuePoosition;
  int? myPosition;

  //To handle request Type
  String? _requestType;
  String byTextIndications = '';
  String byAudioIndicationsURL = '';

  //for listeners
  StreamSubscription<DatabaseEvent>? driverPositionListener;
  StreamSubscription<DatabaseEvent>? passengerRequestListener;
  StreamSubscription<DatabaseEvent>? secondPassengerRequestListener;
  StreamSubscription<DatabaseEvent>? driverStatusListener;

  //For icons
  BitmapDescriptor? taxiIcon;
  Marker? _taxiMarker;

  //GETTERS
  bool get driverInQueue => _driverInQueue;
  int? get currenQueuePoosition => _currenQueuePoosition;
  Polyline get polylineFromPickUpToDropOff => _polylineFromPickUpToDropOff;
  Set<Marker> get markers => _markers;
  PassengerInformation? get passengerInformation => _passengerInformation;
  PassengerRequest? get secondPassenger => _secondPassenger;
  String get driverRideStatus => _driverRideStatus;
  String? get requestType => _requestType;
  Marker? get taxiMarker => _taxiMarker;

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

  set secondPassenger(PassengerRequest? value) {
    _secondPassenger = value;
    notifyListeners();
  }

  set driverRideStatus(String value) {
    _driverRideStatus = value;
    notifyListeners();
  }

  set requestType(String? value) {
    _requestType = value;
    notifyListeners();
  }

  set taxiMarker(Marker? value) {
    _taxiMarker = value;
    notifyListeners();
  }

  //Functinons
  void cancelListeners() {
    driverPositionListener?.cancel();
    passengerRequestListener?.cancel();
    secondPassengerRequestListener?.cancel();
    driverStatusListener?.cancel();
  }

  //FUNCTIONS

  Future<void> animateToLocation(Position target) async {
    if (!mapController.isCompleted) {
      return;
    }
    // Ensure the controller is available

    final GoogleMapController controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(target.latitude, target.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  //On map created
  void onMapCreated(GoogleMapController controller) async {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  //Icons
  void loadIcons() async {
    taxiIcon = await RideHistoryUtil.convertImageToBitmapDescriptor(
        'assets/img/taxi.png');
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
          //get coordinates
          final coords = event.snapshot.value as Map;
          final LatLng driverCoords = LatLng(
              coords['latitude'].toDouble(), coords['longitude'].toDouble());
          //Update our Icon
          if (taxiIcon != null) {
            taxiMarker = Marker(
                markerId: const MarkerId("taxi_marker"),
                position: driverCoords,
                icon: taxiIcon!);
          }

          //When There is a passenger
          if (passengerInformation != null) {
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
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/passenger');
    try {
      passengerRequestListener =
          databaseRef.onValue.listen((DatabaseEvent event) {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          logger.f("New passenger detectedd: ${event.snapshot.value}");
          try {
            // Get the status value
            final dataCatched = event.snapshot.value as Map;
            final passangerInfo = dataCatched['information'];
            passengerId = dataCatched['passengerId'];
            requestType = dataCatched['type'];
            byAudioIndicationsURL = passangerInfo['audioFilePath'];
            byTextIndications = passangerInfo['indicationText'];

            final PassengerInformation tempPassengerInformation =
                PassengerInformation.fromMap(passangerInfo);

            //Update passenger information
            passengerInformation = tempPassengerInformation;
            //Update Driver ride status
            driverRideStatus = DriverRideStatus.goingToPickUp;
            //Add markers only if request type is 'byCoordinates'
            if (requestType == RequestType.byCoordinates) {
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
            }
            //Play sound
            sharedUtil.playAudio('sounds/nuevo_pedido.mp3');
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

  //To listen another passenger.
  void listenToSecondPassangerRequest() {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/secondPassenger');
    secondPassengerRequestListener = databaseRef.onValue.listen((event) {
      // Check if the snapshot has data
      if (event.snapshot.exists) {
        try {
          // Get the status value
          final dataCatched = event.snapshot.value as Map;
          final PassengerRequest tempPassengerInformation =
              PassengerRequest.fromMap(dataCatched);
          //Update passenger information
          secondPassenger = tempPassengerInformation;

          logger.i(
              "SECOND PASSENGER CATCHED: ${tempPassengerInformation.toMap()} raw data: ${event.snapshot.value}");
        } catch (e) {
          logger.e("Error trying to get data of second passenger: $e");
          secondPassenger = null;
        }
      } else {
        secondPassenger = null;
      }
    });
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
              //save ride history
              await _saveRideHistory(sharedProvider);
              //
              await RideRequestService.removePassengerInfo();

              //Check if there is a second passenger waiting
              if (secondPassenger != null) {
                updateDriverStatus(DriverRideStatus.goingToPickUp);
                await RideRequestService.addPassengerDataToRequest(
                    secondPassenger!);
                await RideRequestService.removesecondPassengerInfo();
              }

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

  //Save ride history
  Future<void> _saveRideHistory(SharedProvider sharedProvider) async {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("driver is not authenticated");
      return;
    }
    if (passengerId == null) {
      logger.e("There is not passenger");
      return;
    }
    try {
      RideHistoryModel rideHistory = RideHistoryModel(
        driverId: driverId,
        passengerId: passengerId!,
        pickupCoords: passengerInformation!.pickUpCoordinates,
        dropoffCoords: passengerInformation!.dropOffCoordinates,
        pickUpLocation: passengerInformation!.pickUpLocation,
        dropOffLocation: passengerInformation!.dropOffLocation,
        startTime: Timestamp.now(),
        endTime: Timestamp.now(),
        distance: 0.1,
        driverName: sharedProvider.driverModel!.name,
        passengerName: passengerInformation!.name,
        status: driverRideStatus,
        requestType: requestType!,
        audioFilePath: passengerInformation!.audioFilePath,
        indicationText: passengerInformation!.indicationText,
      );
      await RideRequestService.uploadRideHistory(rideHistory);
    } catch (e) {
      logger.e("Error trying to save ride history: $e");
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

  //Book position in queue
  Future<void> bookPositionInQueue() async {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    driverInQueue =
        await RideRequestService.bookDriverPositionInQueue(idUsuario: driverId);
  }

//Stream to get drivers ordered bassed on timestamp field
  Stream<int?> getDriverPositionInQueue() {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return const Stream.empty();
    }
    final DatabaseReference driversRef =
        FirebaseDatabase.instance.ref('positions');
    return driversRef.orderByChild('timestamp').onValue.map((event) {
      final drivers = event.snapshot.value as Map?;
      // logger.f("Data fetchedL: $drivers");
      if (drivers != null) {
        final sortedDrivers = drivers.entries.toList()
          ..sort((a, b) => (a.value['timestamp'] as int)
              .compareTo(b.value['timestamp'] as int));
        //  logger.f("Sorted drivers: $sortedDrivers");
        for (int i = 0; i < sortedDrivers.length; i++) {
          if (sortedDrivers[i].key == driverId) {
            return i + 1; // Return the position (1-based index)
          }
        }
      }
      return null; // Return null if the driver is not in the queue
    });
  }
}
