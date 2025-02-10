import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/features/delivery_request/view/widgets/delivery_request_type.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class DeliveryRequestListTile extends StatelessWidget {
  final DeliveryRequestModel deliveryRequestModel;

  const DeliveryRequestListTile({
    super.key,
    required this.deliveryRequestModel,
  });

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);

    return GestureDetector(
      onTap: () async {
        //Update Delivery request model in provider
        deliveryRequestViewModel.deliveryRequestModel = deliveryRequestModel;
        //    sharedProvider.passengerInformation = deliveryRequestModel.information;
        //Write driver data in realtime database
        await deliveryRequestViewModel
            .writeDriverDataUnderDeliveryRequest(sharedProvider);
        //Navigate to map page, display info and start navigating
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
                      child: deliveryRequestModel
                              .information.profilePicture.isEmpty
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 24.0)
                          : FadeInImage.assetNetwork(
                              placeholder: 'assets/img/default_profile.png',
                              image: deliveryRequestModel
                                  .information.profilePicture,
                              fadeInDuration: const Duration(milliseconds: 50),
                              width: 100,
                              height: 100,
                            ),
                    ),
                  ),
                  Text(
                    deliveryRequestModel.information.name,
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
                    //reqeust type
                    DeliveryRequestTypeCard(
                        requestType: deliveryRequestModel.requestType),
                    if (deliveryRequestModel.requestType ==
                        RequestType.byCoordinates)
                      Column(
                        children: [
                          Text(
                            deliveryRequestModel.information.pickUpLocation,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            deliveryRequestModel.information.dropOffLocation,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
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
                              Flexible(
                                child: Text(
                                  deliveryRequestModel.details.details,
                                  style: TextStyle(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
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
