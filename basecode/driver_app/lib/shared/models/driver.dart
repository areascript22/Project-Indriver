import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String id;
  final String name;
  final String profilePicture;
  final String email;
  final String phone;
  final Ratings ratings;
  final String role;
  final String license;
  final Vehicle vehicle;

  Driver({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.email,
    required this.phone,
    required this.ratings,
    required this.role,
    required this.license,
    required this.vehicle,
  });
  factory Driver.fromDocument(DocumentSnapshot doc, String uId) => Driver(
        id: uId,
        name: doc['name'],
        phone: doc['phone'],
        profilePicture: doc['profilePicture'],
        email: doc['email'],
        ratings: Ratings.fromMap(doc['ratings']),
        license: doc['license'],
        role: doc['role'],
        vehicle: Vehicle.fromMap(doc['vehicle']),
      );


}

class Ratings {
  final double rating;
  final int ratingCount;
  final double totalRatingScore;

  Ratings({
    required this.rating,
    required this.ratingCount,
    required this.totalRatingScore,
  });

  factory Ratings.fromMap(Map<String, dynamic> map) {
    return Ratings(
      rating: map['rating'].toDouble(),
      ratingCount: map['ratingCount'],
      totalRatingScore: map['totalRatingScore'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'ratingCount': ratingCount,
      'totalRatingScore': totalRatingScore,
    };
  }
}

class Vehicle {
  final String carRegistrationNumber;
  final String code;
  final String model;

  Vehicle({
    required this.carRegistrationNumber,
    required this.code,
    required this.model,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      carRegistrationNumber: map['carRegistrationNumber'],
      code: map['code'],
      model: map['model'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carRegistrationNumber': carRegistrationNumber,
      'code': code,
      'model': model,
    };
  }
}
