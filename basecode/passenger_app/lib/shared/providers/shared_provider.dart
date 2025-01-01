import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';

class SharedProvider extends ChangeNotifier {
  PassengerModel?
      passengerModel; //To user PassengerModel data across multiple Features
  //Features: Map, RequestDriver
  String? _pickUpLocation;
  String? _dropOffLocation;
  LatLng? _pickUpCoordenates;
  LatLng? _dropOffCoordenates;
  Set<Polyline> _polylines = {};
  Polyline polylineFromPickUpToDropOff =
      const Polyline(polylineId: PolylineId("default"));
  String? _duration;
  bool _requestDriverOrDelivery = false; //False= driver, True:Delivery

  //GETTERS
  String? get pickUpLocation => _pickUpLocation;
  String? get dropOffLocation => _dropOffLocation;
  LatLng? get pickUpCoordenates => _pickUpCoordenates;
  LatLng? get dropOffCoordenates => _dropOffCoordenates;
  Set<Polyline> get polylines => _polylines;
  String? get duration => _duration;
  bool get requestDriverOrDelivery => _requestDriverOrDelivery;

  //SETTTERS
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

  set polylines(Set<Polyline> value) {
    _polylines = value;
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
}
