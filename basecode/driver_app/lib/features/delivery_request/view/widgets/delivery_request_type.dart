import 'package:driver_app/shared/models/request_type.dart';
import 'package:flutter/material.dart';

class DeliveryRequestTypeCard extends StatelessWidget {
  final String requestType;
  const DeliveryRequestTypeCard({
    super.key,
    required this.requestType,
  });

  @override
  Widget build(BuildContext context) {
    String requestType = '';
    switch (requestType) {
      case RequestType.byCoordinates:
        requestType = "Coordenadas";
        break;
      case RequestType.byRecordedAudio:
        requestType = "Mensaje de voz";
        break;
      case RequestType.byTexting:
        requestType = "Mensaje de texto";
        break;
      default:
        requestType = "Por defecto";
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50], // Light blue background
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Text(
        requestType, // Example request type
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue[800], // Dark blue text
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
