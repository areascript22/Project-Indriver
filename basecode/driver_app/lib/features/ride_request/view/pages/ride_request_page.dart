import 'package:driver_app/features/home/view/widgets/custom_drawer.dart';
import 'package:driver_app/features/ride_request/view/widgets/driver_queue.dart';
import 'package:driver_app/features/ride_request/view/widgets/passenger_info_card.dart';
import 'package:driver_app/features/ride_request/view/widgets/second_passenger_tile.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/widgets/custom_circular_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class RideMRequestPage extends StatefulWidget {
  const RideMRequestPage({super.key});

  @override
  State<RideMRequestPage> createState() => _RideMRequestPageState();
}

class _RideMRequestPageState extends State<RideMRequestPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final logger = Logger();
  late RideRequestViewModel providerToDispose;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final rideRequestViewModel =
        Provider.of<RideRequestViewModel>(context, listen: false);
    providerToDispose = rideRequestViewModel;
    rideRequestViewModel.listenToDriverCoordenatesInFirebase(sharedProvider);
    rideRequestViewModel.listenerToPassengerRequest(sharedProvider);
    rideRequestViewModel.listenToSecondPassangerRequest();
    rideRequestViewModel.listenToDriverStatus(sharedProvider);
    rideRequestViewModel.loadIcons();
  }

  @override
  void dispose() {
    providerToDispose.cancelListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    rideRequestViewModel.rideRequestPageContext = context;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: rideRequestViewModel.secondPassenger != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(100.0),
                child: SecondPassengerTile(
                    secondPassengerInfo:
                        rideRequestViewModel.secondPassenger!.information),
              )
            : null,
      ),
      drawer: const CustomDrawer(),
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
            markers: {
              ...rideRequestViewModel.markers,
              rideRequestViewModel.taxiMarker ??
                  const Marker(markerId: MarkerId("test"))
            },
            polylines: {rideRequestViewModel.polylineFromPickUpToDropOff},
            onMapCreated: (controller) {
               rideRequestViewModel.onMapCreated(controller);
            },
          ),
          //Menu
          Positioned(
            top: 5,
            left: 10,
            child: CustomCircularButton(
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
              icon: const Icon(Ionicons.menu_outline),
            ),
          ),
          //Button
          //BUTTON: Select Position Taxi
          //  if (rideRequestViewModel.driverRideStatus == DriverRideStatus.pending)
          Positioned(
            top: 5,
            right: 80,
            child: CustomCircularButton(
              icon: rideRequestViewModel.currenQueuePoosition == null
                  ? const Icon(Ionicons.create_outline)
                  : Text(rideRequestViewModel.currenQueuePoosition.toString()),
              onPressed: () async {
                int? response = await showDriverQueueDialog(context);
                if (response != null) {
                  rideRequestViewModel.currenQueuePoosition = response;
                }
              },
            ),
          ),

          //Go to current location button
          Positioned(
            top: 5,
            right: 10,
            child: CustomCircularButton(
              onPressed: () async {
                //animate camera
                if (sharedProvider.driverCurrentPosition != null) {
                  await rideRequestViewModel
                      .animateToLocation(sharedProvider.driverCurrentPosition!);
                }
              },
              icon: const Icon(Icons.navigation_rounded),
            ),
          ),
          //Passenger Info Card
          const Positioned(
              bottom: 0, left: 0, right: 0, child: PassengerInfoCard()),
        ],
      ),
    );
  }
}
