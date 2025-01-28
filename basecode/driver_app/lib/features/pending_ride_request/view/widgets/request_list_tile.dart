import 'package:driver_app/features/pending_ride_request/model/pending_request_model.dart';
import 'package:driver_app/features/pending_ride_request/viewmodel/pending_ride_request_viewmodel.dart';

import 'package:flutter/material.dart';

import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class PendingRequestListTile extends StatelessWidget {
  final PendingRequestModel deliveryRequestModel;

  const PendingRequestListTile({
    super.key,
    required this.deliveryRequestModel,
  });

  @override
  Widget build(BuildContext context) {
    final pendingRideRequestViewModel =
        Provider.of<PendingRideRequestViewModel>(context);
    return GestureDetector(
      onTap: () async {
        await pendingRideRequestViewModel
            .addDriverToRideRequest(deliveryRequestModel.key);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Profile picture
              Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: ClipOval(
                      child: deliveryRequestModel.profilePicture.isEmpty
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 24.0)
                          : FadeInImage.assetNetwork(
                              placeholder: 'assets/img/default_profile.png',
                              image: deliveryRequestModel.profilePicture,
                              fadeInDuration: const Duration(milliseconds: 50),
                              width: 100,
                              height: 100,
                            ),
                    ),
                  ),
                  Text(
                    deliveryRequestModel.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Row(
                    children: [
                      Icon(
                        Ionicons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      Text("Nuevo"),
                    ],
                  ),
                ],
              ),

              //Content
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deliveryRequestModel.pickUpLocation,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      deliveryRequestModel.dropOffLocation,
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    //Recipient name
                    // const SizedBox(height: 4.0),
                    // Row(
                    //   children: [
                    //     Text(
                    //       'Destinatario',
                    //       style: TextStyle(
                    //           color: Colors.grey[600],
                    //           fontWeight: FontWeight.bold),
                    //     ),
                    //     const SizedBox(width: 4.0),
                    //     Text(
                    //       '·',
                    //       style: TextStyle(color: Colors.grey[600]),
                    //     ),
                    //     const SizedBox(width: 4.0),
                    //     Text(
                    //       deliveryRequestModel.details.recipientName,
                    //       style: TextStyle(color: Colors.grey[600]),
                    //     ),
                    //   ],
                    // ),
                    //Package Details
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Text(
                          'Detalles',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '·',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 4.0),
                        // Text(
                        //   deliveryRequestModel.details.details,
                        //   style: TextStyle(color: Colors.grey[600]),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
