import 'dart:async';

import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/delivery_request/model/delivery_status.dart';
import 'package:driver_app/features/delivery_request/repositorie/delivery_request_service.dart';
import 'package:driver_app/features/delivery_request/view/pages/delivery_map_page.dart';
import 'package:driver_app/features/delivery_request/view/widgets/delivery_star_rating_bottom_sheet.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/route_info.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/shared_service.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:map_launcher/map_launcher.dart';

class DeliveryRequestViewModel extends ChangeNotifier {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final Logger logger = Logger();
  final SharedUtil sharedUtil = SharedUtil();
  bool _loading = true;
  DeliveryRequestModel? deliveryRequestModel;
  String _driverDeliveryStatus = '';
  Completer<GoogleMapController> mapController = Completer();
  Polyline _polylineFromPickUpToDropOff =
      const Polyline(polylineId: PolylineId("default"));
  Set<Marker> _markers = {};
  Marker _carMarker = const Marker(markerId: MarkerId('car_marker'));
  BitmapDescriptor? _carIcon;
  String? _mapMessages;
  BuildContext? deliveryRequestPageContext;

  //for listeners
  StreamSubscription<DatabaseEvent>? driverPositionListener;
  StreamSubscription<DatabaseEvent>? passengerRequestListener;
  StreamSubscription<DatabaseEvent>? driverStatusListener;
  //To  avigate between delivery pages
  int _deliveryPageIndex = 0;

  //GETTERS
  bool get loading => _loading;
  String get driverDeliveryStatus => _driverDeliveryStatus;
  BitmapDescriptor? get carIcon => _carIcon;
  Polyline get polylineFromPickUpToDropOff => _polylineFromPickUpToDropOff;
  Set<Marker> get markers => _markers;
  Marker get carMarker => _carMarker;
  String? get mapMessages => _mapMessages;
  int get deliveryPageIndex => _deliveryPageIndex;

  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set driverDeliveryStatus(String value) {
    _driverDeliveryStatus = value;
    notifyListeners();
  }

  set carIcon(BitmapDescriptor? value) {
    _carIcon = value;
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

  set carMarker(Marker value) {
    _carMarker = value;
    notifyListeners();
  }

  set mapMessages(String? value) {
    _mapMessages = value;
    notifyListeners();
  }

  set deliveryPageIndex(int value) {
    _deliveryPageIndex = value;
    notifyListeners();
  }

  //FUNCTIONS
  void cancelListeners() {
    driverPositionListener?.cancel();
    passengerRequestListener?.cancel();
    driverStatusListener?.cancel();
  }

  //Write Our data into Delivery Request
  Future<void> writeDriverDataUnderDeliveryRequest(
      SharedProvider sharedProvider) async {
    loading = true;
    String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Error while getting driver id");
      return;
    }
    bool dataWritten = await DeliveryRequestService.writeDriverDataOnce(
        deliveryRequestModel!.passengerId,
        sharedProvider.driverCurrentPosition!,
        sharedProvider.driverModel!);
    if (dataWritten && deliveryRequestPageContext != null) {
      await sharedUtil.makePhoneVibrate();
      //Navigate to map delivery page
      // if (deliveryRequestPageContext!.mounted) {
      //   Navigator.push(
      //     deliveryRequestPageContext!,
      //     MaterialPageRoute(
      //       builder: (context) => const DeliveryMapPage(),
      //     ),
      //   );
      // }
      deliveryPageIndex = 1;
      //Update Markers
      markers.add(
        Marker(
          markerId: const MarkerId("pick_up"),
          position: deliveryRequestModel!.information.pickUpCoordinates,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId("drop_off"),
          position: deliveryRequestModel!.information.dropOffCoordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      //Start Driver Delivery Status listener
      _listenToDeliveryRequestStatus(
          deliveryRequestModel!.passengerId, sharedProvider);
      //Update delivery status
      await DeliveryRequestService.updateDeliveryRequestStatus(
          deliveryRequestModel!.passengerId, DeliveryStatus.goingForThePackage);
    } else {
      deliveryRequestModel = null;
      //  sharedProvider.passengerInformation = null;
      ToastMessageUtil.showToast("Pedido expirado");
    }
    loading = false;
  }

  //Show available maps
  void showAvailableMaps(SharedProvider sharedProvider, BuildContext context) {
//Open map opctions to navigate
    Coords destination = Coords(
        deliveryRequestModel!.information.pickUpCoordinates.latitude,
        deliveryRequestModel!.information.pickUpCoordinates.longitude);
    if (driverDeliveryStatus == DeliveryStatus.haveThePackage) {
      destination = Coords(
          deliveryRequestModel!.information.dropOffCoordinates.latitude,
          deliveryRequestModel!.information.dropOffCoordinates.longitude);
    }
    sharedProvider.showAllAvailableMaps(context, destination);
  }

  //Load custom icon
  void loadCustomCarIcon(SharedProvider sharedProvider) async {
    carIcon = await sharedProvider
        .convertImageToBitmapDescriptor("assets/img/taxi.png");
    if (carIcon != null) {
      LatLng currenPosition = LatLng(
          sharedProvider.driverCurrentPosition!.latitude,
          sharedProvider.driverCurrentPosition!.longitude);
      carMarker = Marker(
          markerId: const MarkerId("car_marker"),
          position: currenPosition,
          icon: carIcon!);
    }
  }

  //LISTENER: To Redraw route when there is passenger info
  void listenToDriverCoordenatesInFirebase() {
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
          if (deliveryRequestModel != null) {
            //get coordinates
            final coords = event.snapshot.value as Map;
            final LatLng driverCoords = LatLng(
                coords['latitude'].toDouble(), coords['longitude'].toDouble());
            //Draw Polyline
            LatLng destination =
                deliveryRequestModel!.information.dropOffCoordinates;
            if (driverDeliveryStatus == DeliveryStatus.goingForThePackage) {
              destination = deliveryRequestModel!.information.pickUpCoordinates;
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

            //Update Taxi mark
            if (carIcon != null) {
              carMarker = Marker(
                  markerId: const MarkerId("car_marker"),
                  position: driverCoords,
                  icon: carIcon!);
            }
          }
        }
      });
    } catch (e) {
      logger.e('Error listening to driver coordinates: $e');
    }
  }

  //LISTENER: to lsiten value changes under 'delivery_requests/passengerId/status'
  void _listenToDeliveryRequestStatus(
      String passengerId, SharedProvider sharedProvider) {
    final databaseRef =
        FirebaseDatabase.instance.ref('delivery_requests/$passengerId/status');
    try {
      driverStatusListener =
          databaseRef.onValue.listen((DatabaseEvent event) async {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          // Get the status value
          final status = event.snapshot.value as String;
          switch (status) {
            case DeliveryStatus.goingForThePackage:
              driverDeliveryStatus = DeliveryStatus.goingForThePackage;
              break;
            case DeliveryStatus.haveThePackage:
              driverDeliveryStatus = DeliveryStatus.haveThePackage;
              break;
            case DeliveryStatus.goingToTheDeliveryPoint:
              driverDeliveryStatus = DeliveryStatus.goingToTheDeliveryPoint;
              break;
            case DeliveryStatus.arrivedToTheDeliveryPoint:
              driverDeliveryStatus = DeliveryStatus.arrivedToTheDeliveryPoint;
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

  //Update 'status' field under 'delivery_requests/driverID/status'
  Future<void> updateDeliveryRequestStatus(
      String status, BuildContext context) async {
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
      await DeliveryRequestService.updateDeliveryRequestStatus(
          deliveryRequestModel!.passengerId, status);
      //Update map message
      switch (status) {
        case DeliveryStatus.haveThePackage:
          mapMessages =
              'El cliente ha sido notificado que haz recogido el paquete.';
          break;
        case DeliveryStatus.arrivedToTheDeliveryPoint:
          mapMessages =
              'El cliente ha sido notificado que haz llegado al punto de entraga.';
          break;
        default:
      }
    }
    overlayEntry.remove();
  }

  //Finish the package delivery
  Future<void> finishPackageDelivery(BuildContext context) async {
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
      overlayEntry.remove();
      return;
    }
    //Update Driver Status
    await DeliveryRequestService.updateDeliveryRequestStatus(
        deliveryRequestModel!.passengerId, DeliveryStatus.finished);
    //Remove Driver Request on realtime database
    if (deliveryRequestModel == null) {
      logger.e("Passenger id not found");
      overlayEntry.remove();
      return;
    }
    await DeliveryRequestService.removeDeliveryRequest(
        deliveryRequestModel!.passengerId);

    //show star ratings and Pop this page
    deliveryPageIndex = 0;
    overlayEntry.remove();
  }
}
