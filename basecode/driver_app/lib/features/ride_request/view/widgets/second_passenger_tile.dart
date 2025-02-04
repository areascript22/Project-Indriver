import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SecondPassengerTile extends StatelessWidget {
  final PassengerInformation secondPassengerInfo;
  const SecondPassengerTile({
    super.key,
    required this.secondPassengerInfo,
  });

  @override
  Widget build(BuildContext context) {
    String requestType = '';
    switch (secondPassengerInfo.requestType) {
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Soft shadow
            blurRadius: 8,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: secondPassengerInfo.profilePicture.isEmpty
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 30),
                  )
                : FadeInImage.assetNetwork(
                    placeholder: 'assets/img/default_profile.png',
                    image: secondPassengerInfo.profilePicture,
                    fadeInDuration: const Duration(milliseconds: 150),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(
          secondPassengerInfo.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
            ),
          ],
        ),
        titleAlignment: ListTileTitleAlignment.top,
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Ionicons.chevron_down_outline,
              color: Colors.blueAccent,
            ),
            onPressed: () {},
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    // return Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
    //   width: double.infinity,
    //   decoration: BoxDecoration(
    //     color: Colors.grey[100],
    //     borderRadius: BorderRadius.circular(10),
    //   ),
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     children: [
    //       Row(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           //profile picture
    //           CircleAvatar(
    //             radius: 30,
    //             backgroundColor: Colors.grey[300],
    //             child: ClipOval(
    //               child: secondPassengerInfo.profilePicture.isEmpty
    //                   ? const Icon(Icons.person,
    //                       color: Colors.white, size: 24.0)
    //                   : FadeInImage.assetNetwork(
    //                       placeholder: 'assets/img/default_profile.png',
    //                       image: secondPassengerInfo.profilePicture,
    //                       fadeInDuration: const Duration(milliseconds: 50),
    //                       width: 100,
    //                       height: 100,
    //                     ),
    //             ),
    //           ),
    //           //Name
    //           const SizedBox(width: 10),
    //           Column(
    //             mainAxisAlignment: MainAxisAlignment.start,
    //             children: [
    //               //name
    //               Text(
    //                 secondPassengerInfo.name,
    //                 style: const TextStyle(
    //                     fontWeight: FontWeight.bold, fontSize: 16),
    //               ),
    //               //Reuqest type
    //             ],
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
