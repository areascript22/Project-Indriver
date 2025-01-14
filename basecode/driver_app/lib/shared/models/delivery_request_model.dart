import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryRequestModel {
  final String passengerId;
  final PassengerInformation information;
  final Details details; // Adjust this type to match your details model
  final String status;
  final String timestamp;

  DeliveryRequestModel({
    required this.passengerId,
    required this.information,
    required this.details,
    required this.status,
    required this.timestamp,
  });

  /// Factory constructor to create a DeliveryRequest from a map
  factory DeliveryRequestModel.fromMap(Map map, String passengerId) {
    return DeliveryRequestModel(
      passengerId: passengerId,
      information: PassengerInformation.fromMap(map['information']),
      details: Details.fromMap(map['details']),
      status: map['status'] as String,
      timestamp: map['timestamp'],
    );
  }

  /// Converts the DeliveryRequest instance into a map
  Map<String, dynamic> toMap() {
    return {
      'information': information.toMap(),
      'details': details,
      'status': status,
      'timestamp': timestamp,
    };
  }
}

class Details {
  final String details;
  final String recipientName;

  Details({
    required this.details,
    required this.recipientName,
  });

  /// Factory constructor to create a DeliveryRequest from a map
  factory Details.fromMap(Map map) {
    return Details(
      details: map['details'],
      recipientName: map['recipientName'],
    );
  }

  /// Converts the DeliveryRequest instance into a map
  Map<String, dynamic> toMap() {
    return {
      'details': details,
      'recipientName': recipientName,
    };
  }
}

class PassengerInformation {
  final String name;
  final String phone;
  final String profilePicture;
  final String pickUpLocation;
  final String dropOffLocation;
  final LatLng pickUpCoordinates;
  final LatLng dropOffCoordinates;

  PassengerInformation({
    required this.name,
    required this.phone,
    required this.profilePicture,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.pickUpCoordinates,
    required this.dropOffCoordinates,
  });

  /// Factory constructor to create a PassengerInformation instance from a map
  factory PassengerInformation.fromMap(Map map) {
    return PassengerInformation(
      name: map['name'] as String,
      phone: map['phone'] as String,
      profilePicture: map['profilePicture'] as String,
      pickUpLocation: map['pickUpLocation'] as String,
      dropOffLocation: map['dropOffLocation'] as String,
      pickUpCoordinates: LatLng(
        map['pickUpCoordenates']['latitude'] as double,
        map['pickUpCoordenates']['longitude'] as double,
      ),
      dropOffCoordinates: LatLng(
        map['dropOffCoordenates']['latitude'] as double,
        map['dropOffCoordenates']['longitude'] as double,
      ),
    );
  }

  /// Converts the PassengerInformation instance into a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'profilePicture': profilePicture,
      'pickUpLocation': pickUpLocation,
      'dropOffLocation': dropOffLocation,
      'pickUpCoordenates': {
        'latitude': pickUpCoordinates.latitude,
        'longitude': pickUpCoordinates.longitude,
      },
      'dropOffCoordenates': {
        'latitude': dropOffCoordinates.latitude,
        'longitude': dropOffCoordinates.longitude,
      },
    };
  }
}