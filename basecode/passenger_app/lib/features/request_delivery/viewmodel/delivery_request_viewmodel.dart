import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/features/request_delivery/model/delivery_details_model.dart';
import 'package:passenger_app/features/request_delivery/repositorie/request_delivery_service.dart';
import 'package:passenger_app/features/request_delivery/view/widgets/delivery_arrived_bottom_sheet.dart';
import 'package:passenger_app/features/request_delivery/view/widgets/driver_has_package_bottom_sheet.dart';
import 'package:passenger_app/shared/models/driver_model.dart';
import 'package:passenger_app/shared/models/route_info.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/repositories/shared_service.dart';

class DeliveryRequestViewModel extends ChangeNotifier {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final logger = Logger();
  bool _loading = false;
  DeliveryDetailsModel? _deliveryDetailsModel;

  //Listeners
  StreamSubscription<DatabaseEvent>? driverStatusListener;
  StreamSubscription<DatabaseEvent>? driverAcceptanceListener;
  StreamSubscription<DatabaseEvent>? driverPositionListener;

  //GETTERS
  bool get loading => _loading;
  DeliveryDetailsModel? get deliveryDetailsModel => _deliveryDetailsModel;

  // SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set deliveryDetailsModel(DeliveryDetailsModel? value) {
    _deliveryDetailsModel = value;
    notifyListeners();
  }

  //FUNCTIONS
  // Function to call the static method to write data to Firebase
  Future<void> writeDeliveryRequest(SharedProvider sharedProvider) async {
    // Create a DeliveryDetailsModel instance
    try {
      loading = true;
      //get Passenger id
      String passengerId = FirebaseAuth.instance.currentUser!.uid;

      final deliveryDetails = DeliveryDetailsModel(
        recipientName: deliveryDetailsModel!.recipientName,
        details: deliveryDetailsModel!.details,
      );
      bool dataWritten = await RequestDeliveryService.writeToDatabase(
          passengerId: passengerId,
          model: deliveryDetails,
          passengerModel: sharedProvider.passengerModel!,
          sharedProvider: sharedProvider);
      //Start Listener
      if (dataWritten) {
        _listenToDriverAcceptance(passengerId, sharedProvider);
        sharedProvider.deliveryLookingForDriver = true;
      }
      loading = false;
    } catch (e) {
      logger.e("Error while writter delivery erquest: $e");
    }
  }

  //LISTENER: To listen when a driver accept our delivery request
  void _listenToDriverAcceptance(
      String passengerId, SharedProvider sharedProvider) {
    final databaseRef =
        FirebaseDatabase.instance.ref('delivery_requests/$passengerId/driver');

    try {
      driverAcceptanceListener =
          databaseRef.onValue.listen((DatabaseEvent event) async {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          //Fetch driver
          final driverMap = event.snapshot.value as Map;
          //Get key and body
          String? driverId;
          DriverModel? driver;
          if (driverMap.isNotEmpty) {
            driverId = driverMap.keys.first.toString();
            logger.f('Driver acceptance listner 1.5: ${driverId}');
          }
          if (driverId == null) {
            logger.e("Driver not found..");
            return;
          }
          sharedProvider.deliveryLookingForDriver = false;
          //Get the driver data
          driver = await SharedService.getDriverInformationById(driverId);

          sharedProvider.driverModel = driver;

          //Start Driver Location Listener
          _listenToDriverCoordenates(passengerId, driverId, sharedProvider);
          //Start Delivery Request Status Listener
          _listenToDeliveryRequestStatus(passengerId, sharedProvider);
        } else {
          logger.i('There is no drivers ');
        }
      });
    } catch (e) {
      logger.e('Error listening to driver status: $e');
    }
  }

  //LISTENER: To listen every status of the driver
  void _listenToDeliveryRequestStatus(
      String passengerId, SharedProvider sharedProvider) {
    final Logger logger = Logger();
    final databaseRef =
        FirebaseDatabase.instance.ref('delivery_requests/$passengerId/status');

    try {
      driverStatusListener = databaseRef.onValue.listen((DatabaseEvent event) {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          // Get the status value
          final status = event.snapshot.value as String;
          switch (status) {
            case DeliveryStatus.haveThePackage:
              sharedProvider.deliveryStatus = DeliveryStatus.haveThePackage;
              if (sharedProvider.mapPageContext != null) {
                showDriverHasPackageBotttomSheet(
                    sharedProvider.mapPageContext!);
              }
              break;
            case DeliveryStatus.arrivedToTheDeliveryPoint:
            sharedProvider.deliveryStatus = DeliveryStatus.arrivedToTheDeliveryPoint;
              if (sharedProvider.mapPageContext != null) {
                showDeliveryArrivedBottomSheet(sharedProvider.mapPageContext!);
              }
              break;
            default:
              logger.e("Driver Status not found..");
              break;
          }
        } else {
          logger.i('Driver $passengerId status does not exist.');
        }
      });
    } catch (e) {
      logger.e('Error listening to driver status: $e');
    }
  }

  //LISTENER: To track driver location in real time
  void _listenToDriverCoordenates(
      String passengerId, String driverId, SharedProvider sharedProvider) {
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
          //Update Polyline (Route from Driver to a dynamic destination)
          LatLng destination = sharedProvider.pickUpCoordenates!;
          if (sharedProvider.deliveryStatus == DeliveryStatus.haveThePackage) {
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
}
