import 'package:firebase_database/firebase_database.dart';

class DriverRideStatus {
  static const String goingToPickUp = 'goingToPickUp';
  static const String arrived = 'arrived';
  static const String goingToDropOff = 'goingToDropOff';
  static const String finished = 'finished';
}

class DeliveryStatus {
  static const String goingForThePackage = 'goingForThePackage';
  static const String haveThePackage = 'haveThePackage';
  static const String goingToTheDeliveryPoint = 'goingToTheDeliveryPoint';
  static const String arrivedToTheDeliveryPoint = 'arrivedToTheDeliveryPoint';
  static const String finished = 'finished';
}

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String profilePicture;
  final double rating;
  final String vehicleModel;
  final String carRegistrationNumber;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.profilePicture,
    required this.rating,
    required this.vehicleModel,
    required this.carRegistrationNumber,
  });

  // Factory constructor to create a DriverModel instance from Firestore DocumentSnapshot
  factory DriverModel.fromFirestore(DataSnapshot doc, String id) {
    final data = doc.value as Map<dynamic, dynamic>;
    return DriverModel(
      id: id, // Use the snapshot's key as the ID
      name: data['name'] as String,
      phone: data['phone'] as String,
      profilePicture: data['profilePicture'] as String,
      rating: (data['rating'] as num).toDouble(),
      vehicleModel: data['vehicleModel'] as String,
      carRegistrationNumber: data['carRegistrationNumber'] as String,
    );
  }

  // Factory constructor to create a DriverModel instance from a Map<String, dynamic>
  factory DriverModel.fromMap(Map<String, dynamic> map, String id) {
    return DriverModel(
      id: id,
      name: map['name'] as String,
      phone: map['phone'] as String,
      profilePicture: map['profilePicture'] as String,
      rating: (map['rating'] as num).toDouble(),
      vehicleModel: map['vehicleModel'] as String,
      carRegistrationNumber: map['carRegistrationNumber'] as String,
    );
  }

  // Method to convert a DriverModel instance to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'profilePicture': profilePicture,
      'rating': rating,
      'vehicleModel': vehicleModel,
      'carRegistrationNumber': carRegistrationNumber,
    };
  }

  // Override toString for better debugging
  @override
  String toString() {
    return 'DriverModel(id: $id, name: $name, phone: $phone, profilePicture: $profilePicture, rating: $rating, vehicleModel: $vehicleModel, carRegistrationNumber: $carRegistrationNumber)';
  }
}
