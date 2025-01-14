import 'package:driver_app/features/delivery_request/view/widgets/delivery_info_card.dart';
import 'package:driver_app/features/delivery_request/viewmodel/delivery_request_viewmodel.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class DeliveryMapPage extends StatefulWidget {
  const DeliveryMapPage({super.key});

  @override
  State<DeliveryMapPage> createState() => _DeliveryMapPageState();
}

class _DeliveryMapPageState extends State<DeliveryMapPage> {
  late DeliveryRequestViewModel providerToDisose;
  @override
  void initState() {
    super.initState();
    loadNecesaryData();
  }

  void loadNecesaryData() {
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    providerToDisose = deliveryRequestViewModel;
    deliveryRequestViewModel.loadCustomCarIcon(sharedProvider);
    deliveryRequestViewModel.listenToDriverCoordenatesInFirebase();
  }

  @override
  void dispose() {
    providerToDisose.cancelListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
                onPressed: () {
                  //Navigator.pop(context);
                },
                child: Text(
                  "cancelar",
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
          ],
        ),
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
                deliveryRequestViewModel.carMarker,
                ...deliveryRequestViewModel.markers
              },
              polylines: {deliveryRequestViewModel.polylineFromPickUpToDropOff},
              onMapCreated: (controller) {},
            ),
            //Messages
            if (deliveryRequestViewModel.mapMessages != null)
              Positioned(
                top: 7,
                left: 55,
                right: 55,
                child: GestureDetector(
                  onTap: () {
                    deliveryRequestViewModel.mapMessages = null;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            deliveryRequestViewModel.mapMessages!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //Delivery information bottom sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  //Map options to navigate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: CustomTextButton(
                          onPressed: () => deliveryRequestViewModel
                              .showAvailableMaps(sharedProvider, context),
                          child: const Text("Navegar"),
                        ),
                      ),
                    ],
                  ),
                  //Deliveru information Bottom Sheet
                  const DeliveryInfoCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
