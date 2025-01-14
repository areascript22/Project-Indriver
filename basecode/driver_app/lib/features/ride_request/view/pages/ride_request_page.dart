import 'package:driver_app/features/ride_request/view/widgets/driver_position_dialog.dart';
import 'package:driver_app/features/ride_request/view/widgets/passenger_info_card.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class RideMRequestPage extends StatefulWidget {
  const RideMRequestPage({super.key});

  @override
  State<RideMRequestPage> createState() => _RideMRequestPageState();
}

class _RideMRequestPageState extends State<RideMRequestPage> {
  late RideRequestViewModel providerToDispose;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    logger.i("RIDE REQUEST PAGE: Initilizaing....");
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final rideRequestViewModel =
        Provider.of<RideRequestViewModel>(context, listen: false);
    providerToDispose = rideRequestViewModel;
    rideRequestViewModel.listenToDriverCoordenatesInFirebase(sharedProvider);
    rideRequestViewModel.listenerToPassengerRequest(sharedProvider);
    rideRequestViewModel.listenToDriverStatus(sharedProvider);
  }

  @override
  void dispose() {
    providerToDispose.cancelListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    // final sharedProvider = Provider.of<SharedProvider>(context);
    rideRequestViewModel.rideRequestPageContext = context;
    return Scaffold(
      body: Stack(
        children: [
          //Map
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-1.648920, -78.677108),
              zoom: 14,
            ),
            markers: {...rideRequestViewModel.markers},
            polylines: {rideRequestViewModel.polylineFromPickUpToDropOff},
            onMapCreated: (controller) {
              // rideRequestViewModel.onMapCreated(controller, sharedProvider);
            },
          ),
          //Button
          //BUTTON: Select Position Taxi
          if (rideRequestViewModel.driverRideStatus == DriverRideStatus.pending)
            Positioned(
              top: 5,
              right: 80,
              child: ElevatedButton(
                onPressed: () async {
                  //Navigate to current location
                  showDialog(
                    context: context,
                    builder: (context) => DriverPositionsDialog(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                  backgroundColor: Colors.blue,
                ),
                child: rideRequestViewModel.currenQueuePoosition == null
                    ? const Icon(
                        Ionicons.add,
                        color: Colors.white,
                        size: 30,
                      )
                    : Text(
                        rideRequestViewModel.currenQueuePoosition.toString()),
              ),
            ),

          //Passenger Info Card
          Positioned(bottom: 0, left: 0, right: 0, child: PassengerInfoCard()),
        ],
      ),
    );
  }
}
