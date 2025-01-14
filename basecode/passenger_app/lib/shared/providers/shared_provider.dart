import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/driver_model.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';

class SharedProvider extends ChangeNotifier {
  final Logger logger = Logger();
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  BuildContext? mapPageContext;
  //Passenger data
  PassengerModel? passengerModel;
  //Driver data
  DriverModel? _driverModel;
  String _driverStatus = ''; //To Track ride status
  String _deliveryStatus = ''; //To track delivery status
  LatLng? _driverCurrentCoordenates;
  BitmapDescriptor? driverIcon;
  Marker _driverMarker = const Marker(markerId: MarkerId("taxi_marker"));

  //
  String? _pickUpLocation;
  String? _dropOffLocation;
  LatLng? _pickUpCoordenates;
  LatLng? _dropOffCoordenates;
  Polyline _polylineFromPickUpToDropOff =
      const Polyline(polylineId: PolylineId("default"));
  Set<Marker> _markers = {};

  String? _duration;
  bool _requestDriverOrDelivery = false; //False= driver, True:Delivery
  bool _selectingPickUpOrDropOff =
      true; //True:selectin pick up location, else DropOff
  bool _deliveryLookingForDriver = false;

  //GETTERS
  DriverModel? get driverModel => _driverModel;
  String get driverStatus => _driverStatus;
  String get deliveryStatus => _deliveryStatus;
  LatLng? get driverCurrentCoordenates => _driverCurrentCoordenates;
  String? get pickUpLocation => _pickUpLocation;
  String? get dropOffLocation => _dropOffLocation;
  LatLng? get pickUpCoordenates => _pickUpCoordenates;
  LatLng? get dropOffCoordenates => _dropOffCoordenates;
  Polyline get polylineFromPickUpToDropOff => _polylineFromPickUpToDropOff;
  Set<Marker> get markers => _markers;

  Marker get driverMarker => _driverMarker;
  String? get duration => _duration;
  bool get requestDriverOrDelivery => _requestDriverOrDelivery;
  bool get selectingPickUpOrDropOff => _selectingPickUpOrDropOff;
  bool get deliveryLookingForDriver => _deliveryLookingForDriver;

  //SETTTERS
  set driverModel(DriverModel? value) {
    _driverModel = value;
    notifyListeners();
  }

  set driverStatus(String value) {
    _driverStatus = value;
    notifyListeners();
  }

  set deliveryStatus(String value) {
    _deliveryStatus = value;
    notifyListeners();
  }

  set driverCurrentCoordenates(LatLng? value) {
    _driverCurrentCoordenates = value;
    notifyListeners();
  }

  set pickUpLocation(String? value) {
    _pickUpLocation = value;
    notifyListeners();
  }

  set dropOffLocation(String? value) {
    _dropOffLocation = value;
    notifyListeners();
  }

  set pickUpCoordenates(LatLng? value) {
    _pickUpCoordenates = value;
    notifyListeners();
  }

  set dropOffCoordenates(LatLng? value) {
    _dropOffCoordenates = value;
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

  set driverMarker(Marker value) {
    _driverMarker = value;
    notifyListeners();
  }

  set duration(String? value) {
    _duration = value;
    notifyListeners();
  }

  set requestDriverOrDelivery(bool value) {
    _requestDriverOrDelivery = value;
    notifyListeners();
  }

  set selectingPickUpOrDropOff(bool value) {
    _selectingPickUpOrDropOff = value;
    notifyListeners();
  }

  set deliveryLookingForDriver(bool value) {
    _deliveryLookingForDriver = value;
    notifyListeners();
  }

  //FUNCTIONS
}
