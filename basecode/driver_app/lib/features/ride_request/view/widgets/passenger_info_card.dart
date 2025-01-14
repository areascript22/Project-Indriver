import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class PassengerInfoCard extends StatefulWidget {
  const PassengerInfoCard({super.key});

  @override
  State<PassengerInfoCard> createState() => _PassengerInfoCardState();
}

class _PassengerInfoCardState extends State<PassengerInfoCard> {
  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: rideRequestViewModel.passengerInformation != null
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
                                child: rideRequestViewModel
                                        .passengerInformation!
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
                                        image: rideRequestViewModel
                                            .passengerInformation!
                                            .profilePicture,
                                      ),
                              ),
                            ),
                            Text(
                              rideRequestViewModel.passengerInformation!.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const Text("Nuevo"),
                            // Row(
                            //   children: [
                            //     const Icon(Icons.star, size: 16, color: Colors.yellow),
                            //     if (mapDataProvider.user!.totalTrips >= 2)
                            //       Text(
                            //           "${mapDataProvider.user!.rating.toString()}(${mapDataProvider.user!.totalTrips})"),
                            //     if (mapDataProvider.user!.totalTrips < 2) const Text("Nuevo"),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      //Locations pick-up and drop-off
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(),
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Ionicons.location,
                                        color: Colors.green,
                                      ),
                                      Expanded(
                                        child: Text(
                                          rideRequestViewModel
                                              .passengerInformation!
                                              .pickUpLocation,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Ionicons.location,
                                        color: Colors.blue,
                                      ),
                                      Expanded(
                                        child: Text(
                                          rideRequestViewModel
                                              .passengerInformation!
                                              .dropOffLocation,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //Comunication options (if it is in operation mode)

                      Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Ionicons.chatbox_ellipses_outline),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Ionicons.call_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //BUTTONS
                  //'HE LLEGADO' button
                  if (rideRequestViewModel.driverRideStatus ==
                      DriverRideStatus.goingToPickUp)
                    CustomElevatedButton(
                      onTap: () {
                        rideRequestViewModel
                            .updateDriverStatus(DriverRideStatus.arrived);
                      },
                      child: const Text("He llegado"),
                    ),
                  //MESSAGE ""
                  if (rideRequestViewModel.driverRideStatus ==
                      DriverRideStatus.arrived)
                    const Text("El pasajero ha sido notificado.."),
                  //'HE LLEGADO' button
                  if (rideRequestViewModel.driverRideStatus ==
                      DriverRideStatus.goingToDropOff)
                  CustomElevatedButton(
                    onTap: () async {
                      //Update Status to "arrived" to notify Passenger
                      rideRequestViewModel
                          .updateDriverStatus(DriverRideStatus.finished);
                      //Update to "pending" to be able to accept requests again
                      rideRequestViewModel
                          .updateDriverStatus(DriverRideStatus.pending);
                    },
                    child: const Text("Finalizar viaje"),
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }
}
