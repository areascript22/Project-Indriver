import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/core/utils/dialog_util.dart';
import 'package:passenger_app/features/home/view/widgets/custom_drawer.dart';
import 'package:passenger_app/features/map/view/widgets/circular_button.dart';
import 'package:passenger_app/features/request_driver/view/pages/request_delivery_bottom_sheet.dart';
import 'package:passenger_app/features/request_driver/view/pages/request_driver_bottom_sheet.dart';
import 'package:passenger_app/features/map/view/widgets/select_location_icon.dart';
import 'package:passenger_app/features/map/viewmodel/map_view_model.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    //Adign A value to our
    initializeNeccesaryData();
  }

  void initializeNeccesaryData() {
    final mapViewModel = Provider.of<MapViewModel>(context, listen: false);
    mapViewModel.initializeAnimations(this);
  }

  @override
  Widget build(BuildContext context) {
    final mapViewModel = Provider.of<MapViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Scaffold(
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
              target: LatLng(-3.624649, -79.237945),
              zoom: 14,
            ),
            polylines: sharedProvider.polylines,
            markers: mapViewModel.markers,
            onMapCreated: (controller) {
              if (!mapViewModel.mapController.isCompleted) {
                mapViewModel.mapController.complete(controller);
              }
            },
            onCameraMove: (position) {
              if (mapViewModel.enteredInSelectingLocationMode ||
                  (!mapViewModel.enteredInSelectingLocationMode &&
                      sharedProvider.dropOffCoordenates == null)) {
                if (mapViewModel.selectingPickUpOrDropOff) {
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
          if (mapViewModel.enteredInSelectingLocationMode ||
              sharedProvider.dropOffLocation == null)
            SelectLocationIcon(
              mainIconSize: mapViewModel.mainIconSize,
              childT: mapViewModel.isMovingMap
                  ? const CircularProgressIndicator()
                  : mapViewModel.selectingPickUpOrDropOff
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
          //Menu Icon
          if (!mapViewModel.enteredInSelectingLocationMode)
            Positioned(
              top: 40,
              left: 20,
              child: CircularButton(
                onPressed: () {},
                icon: const Icon(Icons.menu),
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
                  mapViewModel.selectingPickUpOrDropOff = true;
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
              !sharedProvider.requestDriverOrDelivery)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RequestDriverBottomSheet(),
            ),
          //Request Delivery Bottom sheet
          if (!mapViewModel.isMovingMap &&
              !mapViewModel.enteredInSelectingLocationMode &&
              sharedProvider.requestDriverOrDelivery)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RequestDeliveryBottomSheet(),
            ),
        ],
      ),
    );
  }
}
