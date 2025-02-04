import 'package:driver_app/features/delivery_request/model/delivery_status.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/features/delivery_request/view/widgets/delivery_request_type.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class DeliveryInfoCard extends StatefulWidget {
  const DeliveryInfoCard({super.key});

  @override
  State<DeliveryInfoCard> createState() => _DeliveryInfoCardState();
}

class _DeliveryInfoCardState extends State<DeliveryInfoCard> {
  final sharedUtil = SharedUtil();
  @override
  Widget build(BuildContext context) {
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: deliveryRequestViewModel.deliveryRequestModel != null
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  //Passenger Info.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Porfile pic
                      Container(
                        decoration: const BoxDecoration(),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 30,
                              child: ClipOval(
                                child: deliveryRequestViewModel
                                        .deliveryRequestModel!
                                        .information
                                        .profilePicture
                                        .isEmpty
                                    ? const Icon(Icons.person,
                                        color: Color.fromARGB(255, 64, 58, 58),
                                        size: 24.0)
                                    : FadeInImage.assetNetwork(
                                        width: 100,
                                        height: 100,
                                        placeholder:
                                            'assets/img/default_profile.png',
                                        image: deliveryRequestViewModel
                                            .deliveryRequestModel!
                                            .information
                                            .profilePicture),
                              ),
                            ),
                            Text(
                              deliveryRequestViewModel
                                  .deliveryRequestModel!.information.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const Text("Nuevo"),
                          ],
                        ),
                      ),
                      //Locations pick-up and drop-off
                      const SizedBox(width: 20),
                      //Center content

                      //Reqeust type card

                      //Coords

                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //type
                              DeliveryRequestTypeCard(
                                  requestType: deliveryRequestViewModel
                                      .deliveryRequestModel!.requestType),
                              //coords
                              if (deliveryRequestViewModel
                                      .deliveryRequestModel!.requestType ==
                                  RequestType.byCoordinates)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Pick Up location
                                    Row(
                                      children: [
                                        const Icon(
                                          Ionicons.location,
                                          color: Colors.green,
                                        ),
                                        Expanded(
                                          child: Text(
                                            deliveryRequestViewModel
                                                .deliveryRequestModel!
                                                .information
                                                .pickUpLocation,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //Drop off location
                                    Row(
                                      children: [
                                        const Icon(
                                          Ionicons.location,
                                          color: Colors.blue,
                                        ),
                                        Expanded(
                                          child: Text(
                                            deliveryRequestViewModel
                                                .deliveryRequestModel!
                                                .information
                                                .dropOffLocation,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    //Details
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
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 4.0),
                                        Text(
                                          deliveryRequestViewModel
                                              .deliveryRequestModel!
                                              .details
                                              .details,
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),

                      //Comunication options
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              sharedUtil.sendSMS(
                                  deliveryRequestViewModel
                                      .deliveryRequestModel!.information.phone,
                                  '');
                            },
                            icon: const Icon(Ionicons.call_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //BUTTONS
                  //'HE LLEGADO' button
                  if (deliveryRequestViewModel.driverDeliveryStatus ==
                      DeliveryStatus.goingForThePackage)
                    CustomElevatedButton(
                      onTap: () =>
                          deliveryRequestViewModel.updateDeliveryRequestStatus(
                              DeliveryStatus.haveThePackage, context),
                      child: const Text("Tengo el paquete"),
                    ),

                  //'HE LLEGADO' button
                  if (deliveryRequestViewModel.driverDeliveryStatus ==
                      DeliveryStatus.haveThePackage)
                    CustomElevatedButton(
                      onTap: () =>
                          deliveryRequestViewModel.updateDeliveryRequestStatus(
                              DeliveryStatus.arrivedToTheDeliveryPoint,
                              context),
                      child: const Text("He llegado con el paquete"),
                    ),
                  //'FINALIZAR' button
                  if (deliveryRequestViewModel.driverDeliveryStatus ==
                      DeliveryStatus.arrivedToTheDeliveryPoint)
                    CustomElevatedButton(
                      onTap: () async {
                        await deliveryRequestViewModel
                            .finishPackageDelivery(context);
                      },
                      child: const Text("Finalizar entraga"),
                    ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }
}
