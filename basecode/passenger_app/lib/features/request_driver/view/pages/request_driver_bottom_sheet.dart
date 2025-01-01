import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/features/request_driver/view/widgets/bs_elevated_button.dart';
import 'package:passenger_app/features/request_driver/view/widgets/bs_text_field.dart';
import 'package:passenger_app/features/request_driver/view/widgets/custom_image_button.dart';
import 'package:passenger_app/features/request_driver/viewmodel/request_driver_viewmodel.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/widgets/custom_circular_button.dart';
import 'package:passenger_app/features/request_driver/view/widgets/search_locations_bottom_sheet.dart';
import 'package:passenger_app/shared/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

class RequestDriverBottomSheet extends StatefulWidget {
  const RequestDriverBottomSheet({
    super.key,
  });

  @override
  State<RequestDriverBottomSheet> createState() =>
      _RequestDriverBottomSheetState();
}

class _RequestDriverBottomSheetState extends State<RequestDriverBottomSheet> {
  final bool estimatedtime = false;
  int selectedIndex = 1; // Tracks the currently selected button index
  final List<Map> imagePaths = [
    {'path': 'assets/img/delivery.png', 'title': 'Encomiendas'},
    {'path': 'assets/img/car.png', 'title': 'Viajes'},
  ];

  @override
  Widget build(BuildContext context) {
    final sharedViewModel = Provider.of<SharedProvider>(context);
    final requestDriverViewModel = Provider.of<RequestDriverViewModel>(context);
    final referenceTextController = TextEditingController();
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
                          if (selectedIndex != index) {
                            sharedViewModel.requestDriverOrDelivery = true;
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
                    backgroundColor: sharedViewModel.pickUpLocation == null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.background,
                    pickUpDestination: true,
                    icon: const Icon(
                      Ionicons.location,
                      size: 30,
                      color: Colors.red,
                    ),
                    child: sharedViewModel.pickUpLocation == null
                        ? const CircularProgressIndicator()
                        : Text(
                            sharedViewModel.pickUpLocation == null
                                ? "Lugar de recogida"
                                : sharedViewModel.pickUpLocation!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  const SizedBox(height: 10),

                  //Destination Location
                  BSElevatedButton(
                    onPressed: () => showSearchBottomSheet(context, false),
                    backgroundColor: sharedViewModel.dropOffLocation == null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.background,
                    pickUpDestination: false,
                    icon: sharedViewModel.dropOffLocation == null
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
                    child: Expanded(
                      child: Text(
                        sharedViewModel.dropOffLocation == null
                            ? "Destino"
                            : sharedViewModel.dropOffLocation!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //Estimated time
                  // if (estimatedtime)
                  if (sharedViewModel.duration != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Row(
                          children: [
                            const Icon(
                              Ionicons.information_circle_outline,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                                "Tiempo de viaje ~ ${sharedViewModel.duration}"),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  BSTextField(
                      textEditingController: referenceTextController,
                      hintText: "Referencia",
                      leftIcon: Ionicons.reader,
                      rightIcon: Ionicons.pencil),

                  const SizedBox(height: 20),

                  //Request Taxi
                  CustomElevatedButton(
                    onTap: sharedViewModel
                            .polylineFromPickUpToDropOff.points.isNotEmpty
                        ? () => requestDriverViewModel.requestTaxi(context)
                        : null,
                    child: const Text("Solicitar taxi"),
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
