import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/request_type.dart';
import 'package:passenger_app/shared/widgets/custom_drawer.dart';
import 'package:passenger_app/features/map/view/widgets/circular_button.dart';
import 'package:passenger_app/features/request_driver/view/pages/driver_bottom_card.dart';
import 'package:passenger_app/features/request_delivery/view/pages/request_delivery_bottom_sheet.dart';
import 'package:passenger_app/features/request_driver/view/pages/request_driver_bottom_sheet.dart';
import 'package:passenger_app/features/map/view/widgets/select_location_icon.dart';
import 'package:passenger_app/features/map/viewmodel/map_view_model.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/widgets/custom_elevated_button.dart';
import 'package:passenger_app/shared/widgets/waiting_for_drover_overlay.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  final logger = Logger();
  @override
  void initState() {
    super.initState();
    logger.f("Initizlizing Map Page");
    //Adign A value to our
    initializeNeccesaryData();
  }

  void initializeNeccesaryData() {
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);

    mapViewModel.initializeAnimations(this, sharedProvider);
  }

  @override
  Widget build(BuildContext context) {
    final mapViewModel = Provider.of<MapViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    sharedProvider.mapPageContext = context;
    return Scaffold(
      key: scaffoldkey,
      drawer: const CustomDrawer(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          //Map
          GoogleMap(
            // zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-1.666836, -78.651048),
              zoom: 14,
            ),
            polylines: {sharedProvider.polylineFromPickUpToDropOff},
            markers: {
              sharedProvider.driverModel != null
                  ? sharedProvider.driverMarker
                  : const Marker(markerId: MarkerId("defauklt")),
              ...sharedProvider.markers
            },
            onMapCreated: (controller) {
              if (!mapViewModel.mapController.isCompleted) {
                mapViewModel.mapController.complete(controller);
              }
            },
            onCameraMove: (position) {
              if (sharedProvider.requestType != RequestType.byCoordinates) {
                return;
              }
              if (mapViewModel.enteredInSelectingLocationMode ||
                  (!mapViewModel.enteredInSelectingLocationMode &&
                      sharedProvider.dropOffCoordenates == null)) {
                if (sharedProvider.selectingPickUpOrDropOff) {
                  sharedProvider.pickUpCoordenates = position.target;
                } else {
                  sharedProvider.dropOffCoordenates = position.target;
                }
              }
            },
            onCameraMoveStarted: () =>
                mapViewModel.hideBottomSheet(sharedProvider),
            onCameraIdle: () =>
                mapViewModel.showBottomSheetWithDelay(sharedProvider),
          ),
          //Select Location Icon
          if ((mapViewModel.enteredInSelectingLocationMode ||
                  sharedProvider.dropOffLocation == null) &&
              sharedProvider.requestType == RequestType.byCoordinates)
            SelectLocationIcon(
              mainIconSize: mapViewModel.mainIconSize,
              childT: mapViewModel.isMovingMap
                  ? const CircularProgressIndicator()
                  : sharedProvider.selectingPickUpOrDropOff
                      ? sharedProvider.pickUpLocation != null
                          ? Text(sharedProvider.pickUpLocation!)
                          : const CircularProgressIndicator(
                              color: Colors.blue,
                            )
                      : sharedProvider.dropOffLocation != null
                          ? Text(sharedProvider.dropOffLocation!)
                          : const CircularProgressIndicator(
                              color: Colors.blue,
                            ),
            ),
          //     Menu Icon
          if (!mapViewModel.enteredInSelectingLocationMode)
            Positioned(
              top: 10,
              left: 15,
              child: CircularButton(
                onPressed: () => scaffoldkey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),

          //Go to current location button
          Positioned(
            top: 10,
            right: 10,
            child: CircularButton(
              onPressed: () {
                // mapViewModel
                //     .animateCameraToPosition(LatLng(-1.663946, -78.672757));
                mapViewModel.getCurrentLocationAndNavigate();
              },
              icon: const Icon(Icons.navigation_rounded),
            ),
          ),

          //Return to Select Pick Up
          if (mapViewModel.enteredInSelectingLocationMode)
            Positioned(
              top: 40,
              left: 20,
              child: CircularButton(
                onPressed: () {
                  mapViewModel.enteredInSelectingLocationMode = false;
                  sharedProvider.selectingPickUpOrDropOff = true;
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          //Button "Hecho"
          if (mapViewModel.enteredInSelectingLocationMode)
            Positioned(
              left: 50,
              right: 50,
              bottom: 20,
              child: CustomElevatedButton(
                onTap: () async {
                  //draw route
                  await mapViewModel.drawRouteBetweenTwoPoints(sharedProvider);
                  //Return
                  mapViewModel.enteredInSelectingLocationMode = false;
                },
                color: Colors.blue,
                child: mapViewModel.loading
                    ? const CircularProgressIndicator()
                    : const Text("Hecho"),
              ),
            ),

          //Request Driver Bottom sheet
          if (!mapViewModel.isMovingMap &&
              !mapViewModel.enteredInSelectingLocationMode &&
              !sharedProvider.requestDriverOrDelivery &&
              sharedProvider.driverModel == null)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RequestDriverBottomSheet(),
            ),
          //Request Delivery Bottom sheet
          if (!mapViewModel.isMovingMap &&
              !mapViewModel.enteredInSelectingLocationMode &&
              sharedProvider.requestDriverOrDelivery &&
              sharedProvider.driverModel == null)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RequestDeliveryBottomSheet(),
            ),

          //WHEN DRIVER IS COMMING.
          if (sharedProvider.driverModel != null)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DriverBottomCard(),
            ),

          // Overlay
          if (sharedProvider.deliveryLookingForDriver)
            Positioned.fill(
              child: WitingForDriverOverlay(),
            ),
        ],
      ),
    );
  }
}
