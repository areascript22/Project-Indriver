import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:passenger_app/features/request_delivery/viewmodel/delivery_request_viewmodel.dart';
import 'package:passenger_app/shared/widgets/bs_elevated_button.dart';
import 'package:passenger_app/shared/widgets/custom_image_button.dart';
import 'package:passenger_app/features/request_delivery/view/widgets/delivery_details_bottom_sheet.dart';
import 'package:passenger_app/features/request_delivery/view/widgets/delivery_details_button.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/widgets/custom_circular_button.dart';
import 'package:passenger_app/shared/widgets/search_locations_bottom_sheet.dart';
import 'package:passenger_app/shared/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

class RequestDeliveryBottomSheet extends StatefulWidget {
  const RequestDeliveryBottomSheet({
    super.key,
  });

  @override
  State<RequestDeliveryBottomSheet> createState() =>
      _RequestDeliveryBottomSheetState();
}

class _RequestDeliveryBottomSheetState
    extends State<RequestDeliveryBottomSheet> {
  final bool estimatedtime = false;
  int selectedIndex = 0; // Tracks the currently selected button index
  final List<Map> imagePaths = [
    {'path': 'assets/img/delivery.png', 'title': 'Encomiendas'},
    {'path': 'assets/img/car.png', 'title': 'Viajes'},
  ];
  bool showEncompleteFieldError = false;

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    final deliveryRequestViewModel =
        Provider.of<DeliveryRequestViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCircularButton(
            onPressed: () {
              // mapPageController.fitBounds(value);
            },
            icon: const Icon(Icons.zoom_in)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          // height: 320,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(2, (index) {
                      return CustomImageButton(
                        imagePath: imagePaths[index]['path'],
                        title: imagePaths[index]['title'],
                        isSelected: selectedIndex == index,
                        onTap: () {
                          if (index != selectedIndex) {
                            sharedProvider.requestDriverOrDelivery = false;
                          }
                          selectedIndex = index; // Update the selected button
                          setState(() {});
                        },
                      );
                    }),
                  ),
                  //Pick up location
                  const SizedBox(height: 10),
                  BSElevatedButton(
                    onPressed: () => showSearchBottomSheet(context, true),
                    backgroundColor: sharedProvider.pickUpLocation == null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.background,
                    pickUpDestination: true,
                    icon: const Icon(
                      Ionicons.location,
                      size: 30,
                      color: Colors.red,
                    ),
                    child: sharedProvider.pickUpLocation == null
                        ? const CircularProgressIndicator()
                        : Text(
                            sharedProvider.pickUpLocation == null
                                ? "Lugar de recogida"
                                : sharedProvider.pickUpLocation!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  const SizedBox(height: 10),

                  //Destination Location
                  BSElevatedButton(
                    onPressed: () => showSearchBottomSheet(context, false),
                    backgroundColor: sharedProvider.dropOffLocation == null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.background,
                    pickUpDestination: false,
                    icon: sharedProvider.dropOffLocation == null
                        ? const Icon(
                            Ionicons.search,
                            size: 30,
                            color: Colors.black54,
                          )
                        : const Icon(
                            Ionicons.location,
                            size: 30,
                            color: Colors.green,
                          ),
                    child: Text(
                      sharedProvider.dropOffLocation == null
                          ? "Destino"
                          : sharedProvider.dropOffLocation!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  //Delivery Details
                  const SizedBox(height: 15),
                  DeliveryDetailsButton(
                    onPressed: () => showDeliveryDetailsBottomSheet(context),
                  ),
                  //Uncomplete fields message
                  if (showEncompleteFieldError)
                    const Text(
                      "Por favor, complete todos los campos",
                      style: TextStyle(color: Colors.red),
                    ),

                  //Request Delivery Button
                  const SizedBox(height: 10),
                  CustomElevatedButton(
                    onTap: () {
                      //Chech if all field are completed
                      setState(() {
                        showEncompleteFieldError = (sharedProvider
                                .polylineFromPickUpToDropOff.points.isEmpty ||
                            deliveryRequestViewModel.deliveryDetailsModel ==
                                null);
                      });
                      print(
                          "showEncompleteFieldError : $showEncompleteFieldError ");
                      if (showEncompleteFieldError) return;
                      //Write data in Realtime Database
                      deliveryRequestViewModel
                          .writeDeliveryRequest(sharedProvider);
                    },
                    child: deliveryRequestViewModel.loading
                        ? const CircularProgressIndicator()
                        : const Text("Solicitar enconmienda"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
