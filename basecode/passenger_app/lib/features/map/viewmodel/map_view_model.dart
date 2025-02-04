import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/route_info.dart';
import 'package:passenger_app/features/map/repositorie/map_services.dart';
import 'package:image/image.dart' as img;
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/repositories/shared_service.dart';

class MapViewModel extends ChangeNotifier {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  bool _loading = false; //For showing a circular spineer while async funcs
  final Logger logger = Logger();
  late AnimationController animController;
  late Animation<Offset> animOffsetDB; //Drawer Button
  late Animation<Offset> animOfssetBS; //BottomSheet
  Timer? timer;

  //MARKS AND POLYLINES
  double _mainIconSize = 30;
  bool _isMovingMap = false;
  // bool _isRouteDrawn = false;

  bool _enteredInSelectingLocationMode =
      false; //True i am selecting any location
  BitmapDescriptor? pickUpMarker;
  BitmapDescriptor? dropOffMarker;

  Completer<GoogleMapController> mapController = Completer();

  // Set<Polyline> _polylines = {};

  //SEARCH DIRECTIONS BOTTOM SHEET
  bool _searchingDirections = false;
  bool _isPickUpFocussed = false;
  bool _isDropOffFocussed = false;
  List<dynamic> listOfLcoationsPickUp = [];
  List<dynamic> listOfLcoationsDropOff = [];
  final pickUpTextController = TextEditingController();
  final dropOffTextController = TextEditingController();
  final FocusNode pickUpFocusNode = FocusNode();
  final FocusNode dropOffFocusNode = FocusNode();
  Timer? _debounce; // Timer for debouncing

  //GETTERS
  bool get loading => _loading;
  double get mainIconSize => _mainIconSize;
  bool get isMovingMap => _isMovingMap;
  // bool get isRouteDrawn => _isRouteDrawn;

  bool get enteredInSelectingLocationMode => _enteredInSelectingLocationMode;

  bool get searchingDirections => _searchingDirections;
  bool get isPickUpFocussed => _isPickUpFocussed;
  bool get isDropOffFocussed => _isDropOffFocussed;

  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set mainIconSize(double value) {
    _mainIconSize = value;
    notifyListeners();
  }

  set isMovingMap(bool value) {
    _isMovingMap = value;
    notifyListeners();
  }

  // set isRouteDrawn(bool value) {
  //   _isRouteDrawn = value;
  //   notifyListeners();
  // }

  set enteredInSelectingLocationMode(bool value) {
    _enteredInSelectingLocationMode = value;
    notifyListeners();
  }

  set searchingDirections(bool value) {
    _searchingDirections = value;
    notifyListeners();
  }

  set isPickUpFocussed(bool value) {
    _isPickUpFocussed = value;
    notifyListeners();
  }

  set isDropOffFocussed(bool value) {
    _isDropOffFocussed = value;
    notifyListeners();
  }

  //FUNCTIONS

  /// Function to animate the camera to a given LatLng position.
//Animate camera given an location point
  Future<void> animateCameraToPosition(LatLng locationToMove) async {
    GoogleMapController controller = await mapController.future;
    try {
      await controller
          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: locationToMove,
        zoom: 15,
        bearing: 0,
      )));
    } catch (e) {
      logger.e("Error trying to animate map camera: $e");
    }
  }

  //Get and navigate to current location
  void getCurrentLocationAndNavigate() async {
    try {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium)
          .timeout(const Duration(seconds: 7));
      animateCameraToPosition(
        LatLng(position.latitude, position.longitude),
      );
      logger.i("GEt currento location executed...");
      //Animate camera
    } catch (e) {
      logger.e("Error tracking location: $e");
    }
  }

  //Initialize all necesary data
  Future<void> initializeAnimations(
      TickerProvider vsyn, SharedProvider sharedProvider) async {
    //Initialize animation controller
    animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: vsyn,
    );
    animOffsetDB = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(
      CurvedAnimation(
        parent: animController,
        curve: Curves.easeInOut,
      ),
    );
    animOfssetBS = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2),
    ).animate(
      CurvedAnimation(
        parent: animController,
        curve: Curves.easeInOut,
      ),
    );
    //Initialize Markers
    pickUpMarker =
        await convertImageToBitmapDescriptor('assets/img/location1.png');
    dropOffMarker =
        await convertImageToBitmapDescriptor('assets/img/location2.png');
    sharedProvider.driverIcon =
        await convertImageToBitmapDescriptor('assets/img/taxi.png');
  }

//Convert an image from asset into BitmapDescription
  Future<BitmapDescriptor?> convertImageToBitmapDescriptor(String path) async {
    try {
      final ByteData byteData = await rootBundle.load(path);
      final Uint8List bytes = byteData.buffer.asUint8List();
      img.Image originalImage = img.decodeImage(bytes)!;
      img.Image resizedImage =
          img.copyResize(originalImage, width: 100, height: 100);
      final Uint8List resizedBytes =
          Uint8List.fromList(img.encodePng(resizedImage));
      final BitmapDescriptor icon = BitmapDescriptor.fromBytes(resizedBytes);
      return icon;
    } catch (e) {
      return null;
    }
  }

//Hide BottomSheet
  void hideBottomSheet(SharedProvider sharedProvider) {
    animController.forward();
    mainIconSize = 50;
    isMovingMap = true;
    if (enteredInSelectingLocationMode ||
        sharedProvider.dropOffLocation == null) {
      logger.i("Hide bottom sheet func: ");
      if (sharedProvider.selectingPickUpOrDropOff) {
        sharedProvider.pickUpLocation = null;
      }
      if (!sharedProvider.selectingPickUpOrDropOff) {
        sharedProvider.dropOffLocation = null;
      }
    }

    timer?.cancel();
  }

  //To show BootomSheet with delay
  Future<void> showBottomSheetWithDelay(SharedProvider sharedProvider) async {
    timer?.cancel();
    timer = Timer(
      const Duration(milliseconds: 500),
      () async {
        isMovingMap = false;
        animController.reverse();
        mainIconSize = 30;
        if (enteredInSelectingLocationMode ||
            (!enteredInSelectingLocationMode &&
                sharedProvider.dropOffCoordenates == null)) {
          if (sharedProvider.pickUpCoordenates != null &&
              sharedProvider.selectingPickUpOrDropOff) {
            // await getDirectionsText(pickUpCoordenates!);
            sharedProvider.pickUpLocation =
                await MapServices.getReadableAddress(
                    sharedProvider.pickUpCoordenates!.latitude,
                    sharedProvider.pickUpCoordenates!.longitude,
                    apiKey);
            addPickUpOrDropOffMarkerToMap(
                sharedProvider.pickUpCoordenates!, sharedProvider);
          }
          if (sharedProvider.dropOffCoordenates != null &&
              !sharedProvider.selectingPickUpOrDropOff) {
            sharedProvider.dropOffLocation =
                await MapServices.getReadableAddress(
                    sharedProvider.dropOffCoordenates!.latitude,
                    sharedProvider.dropOffCoordenates!.longitude,
                    apiKey);
            addPickUpOrDropOffMarkerToMap(
                sharedProvider.dropOffCoordenates!, sharedProvider);
          }
        }
      },
    );
  }

  // Function to add a marker on map (CALLED BY: MapPage page and SelectDestination page)
  void addPickUpOrDropOffMarkerToMap(
      LatLng position, SharedProvider sharedProvider) {
    //clean markers
    if (sharedProvider.selectingPickUpOrDropOff) {
      sharedProvider.markers.removeWhere(
        (element) => element.markerId == const MarkerId("pick_up"),
      );
    } else {
      sharedProvider.markers.removeWhere(
        (element) => element.markerId == const MarkerId("drop_off"),
      );
    }
    //add marker
    sharedProvider.markers.add(
      Marker(
        markerId: MarkerId(
            sharedProvider.selectingPickUpOrDropOff ? "pick_up" : "drop_off"),
        position: position,
        infoWindow: const InfoWindow(
          title: 'Marker Title',
          snippet: 'Marker Snippet',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            sharedProvider.selectingPickUpOrDropOff
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueBlue),
      ),
    );
  }

  //Draw route
  Future<void> drawRouteBetweenTwoPoints(SharedProvider sharedProvider) async {
    loading = true;
    if (sharedProvider.pickUpCoordenates == null ||
        sharedProvider.dropOffCoordenates == null) {
      logger.e(
          "Valores nuloa al dibujar rutas: pick up coords: ${sharedProvider.pickUpCoordenates} , dropoff coords: ${sharedProvider.dropOffCoordenates}");
      return;
    }
    RouteInfo? routeInfo = await SharedService.getRoutePolylinePoints(
        sharedProvider.pickUpCoordenates!,
        sharedProvider.dropOffCoordenates!,
        apiKey);

    if (routeInfo != null) {
      sharedProvider.polylineFromPickUpToDropOff = Polyline(
        polylineId: const PolylineId("pickUpToDropoff"),
        points: routeInfo.polylinePoints,
        width: 5,
        color: Colors.blue,
      );
      sharedProvider.duration = routeInfo.duration;
    }

    loading = false;
  }

  //Animate map camera to a especific point
  // void animateCameraToPosition(LatLng point) async {
  //   GoogleMapController controller = await mapController.future;
  //   controller.animateCamera(
  //     CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //         target: LatLng(point.latitude, point.longitude),
  //         zoom: 15,
  //         bearing: 0,
  //       ),
  //     ),
  //   );
  // }

  //SEARCH DIRECTIONS BOTTOM SHEET
  //Get autocomplete direction
  Future<void> getAutocompletePlaces(String input) async {
    // Cancel the previous debounce if it exists
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (input.isNotEmpty) {
        loading = true;

        // Call the API
        List<dynamic> response =
            await MapServices.getAutocompletePlaces(input, apiKey);

        // Update the appropriate list based on focus
        if (isPickUpFocussed) {
          listOfLcoationsPickUp = response;
        }
        if (isDropOffFocussed) {
          listOfLcoationsDropOff = response;
        }

        loading = false;
      }
    });
  }

  //Get Coordinates as LatLng by passing the Place id
  Future<void> getCoordinatesByPlaceId(String placeId, BuildContext context,
      SharedProvider sharedProvider) async {
    loading = true;
    LatLng? response =
        await MapServices.getCoordinatesByPlaceId(placeId, apiKey);
    if (response != null) {
      if (isPickUpFocussed) {
        sharedProvider.pickUpCoordenates = response;
        //Pending: Add a Marker to that point
        sharedProvider.pickUpLocation = pickUpTextController.text;
        addPickUpOrDropOffMarkerToMap(
            sharedProvider.pickUpCoordenates!, sharedProvider);
      }
      if (isDropOffFocussed) {
        sharedProvider.dropOffCoordenates = response;
        //Pending: Add a Marker to that point
        sharedProvider.dropOffLocation = dropOffTextController.text;
        addPickUpOrDropOffMarkerToMap(
            sharedProvider.dropOffCoordenates!, sharedProvider);
      }
    }
    if (sharedProvider.pickUpCoordenates != null &&
        sharedProvider.dropOffCoordenates != null) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
    if (isPickUpFocussed) {
      if (context.mounted) {
        logger.i("Is Pick Up Focussed: $isPickUpFocussed");
        FocusScope.of(context).requestFocus(dropOffFocusNode);
      }
    }
    drawRouteBetweenTwoPoints(sharedProvider);
    loading = false;
  }

  //Init text controllers listeners
  void initializeTextControllersLiteners(SharedProvider sharedProvider) {
    if (sharedProvider.pickUpLocation != null) {
      pickUpTextController.text = sharedProvider.pickUpLocation!;
    }
    if (sharedProvider.dropOffLocation != null) {
      dropOffTextController.text = sharedProvider.dropOffLocation!;
    }

    pickUpFocusNode.addListener(() {
      isPickUpFocussed = pickUpFocusNode.hasFocus;
      sharedProvider.selectingPickUpOrDropOff = true;
    });
    dropOffFocusNode.addListener(() {
      isDropOffFocussed = dropOffFocusNode.hasFocus;
      sharedProvider.selectingPickUpOrDropOff = false;
    });
    //FocusTextFields

    //Listener for Text editing controllers
    pickUpTextController.addListener(() {
      getAutocompletePlaces(pickUpTextController.text);
    });
    dropOffTextController.addListener(() {
      getAutocompletePlaces(dropOffTextController.text);
    });
  }
}
