import 'package:passenger_app/shared/models/passenger_model.dart';

class GUser {
  //General user
  final String? id;
  final String name;
  final String? lastName;
  final String email;
  final String phone;
  final String profilePicture;
  final Ratings ratings;
  final List<String> role;
  final Vehicle? vehicle;

  GUser({
    this.id,
    required this.name,
    this.lastName,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.ratings,
    required this.role,
    this.vehicle,
  });

  // Convert a map (Firestore document) to a GUser object
  factory GUser.fromMap(Map map) {
    return GUser(
      id: map['id'],
      name: map['name'] ?? '',
      lastName: map['lastName'],
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      ratings: Ratings.fromMap(map['ratings'] ?? {}),
      role: List<String>.from(map['role'] ?? []),
      vehicle: map['vehicle'] != null ? Vehicle.fromMap(map['vehicle']) : null,
    );
  }

  // Convert a GUser object to a map (Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'ratings': ratings.toMap(),
      'role': role,
      'vehicle': vehicle?.toMap(),
    };
  }
}

class Vehicle {
  final String carRegistrationNumber;
  final String taxiCode;
  final String model;
  final String license;

  // Constructor
  Vehicle({
    required this.carRegistrationNumber,
    required this.taxiCode,
    required this.model,
    required this.license,
  });

  // Convert a Firestore document to a Vehicle object
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      carRegistrationNumber: map['carRegistrationNumber'] ?? '',
      taxiCode: map['taxiCode'] ?? '',
      model: map['model'] ?? '',
      license: map['license'] ?? '',
    );
  }

  // Convert a Vehicle object to a map (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'carRegistrationNumber': carRegistrationNumber,
      'taxiCode': taxiCode,
      'model': model,
      'license': license,
    };
  }
}
