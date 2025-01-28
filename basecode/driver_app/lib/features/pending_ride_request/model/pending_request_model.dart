class PendingRequestModel {
  final String key;
  final String dropOffLocation;
  final String name;
  final String pickUpLocation;
  final String profilePicture;

  PendingRequestModel({
    required this.key,
    required this.dropOffLocation,
    required this.name,
    required this.pickUpLocation,
    required this.profilePicture,
  });

  // Factory method to create an instance from JSON
  factory PendingRequestModel.fromJson(Map json, String key) {
    return PendingRequestModel(
      key: key,
      dropOffLocation: json['dropOffLocation'] != null
          ? json['dropOffLocation'] as String
          : '',
      name: json['name'] as String,
      pickUpLocation: json['pickUpLocation'] != null
          ? json['pickUpLocation'] as String
          : '',
      profilePicture: json['profilePicture'] as String,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'dropOffLocation': dropOffLocation,
      'name': name,
      'pickUpLocation': pickUpLocation,
      'profilePicture': profilePicture,
    };
  }
}
