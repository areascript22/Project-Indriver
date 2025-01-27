import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:passenger_app/features/request_driver/view/widgets/star_ratings_bottom_sheet.dart';
import 'package:passenger_app/shared/models/request_type.dart';
import 'package:passenger_app/features/request_driver/view/widgets/request_driver_by_audio.dart';
import 'package:passenger_app/features/request_driver/view/widgets/request_driver_by_text.dart';
import 'package:passenger_app/shared/widgets/bs_elevated_button.dart';
import 'package:passenger_app/features/request_driver/view/widgets/bs_text_field.dart';
import 'package:passenger_app/shared/widgets/custom_image_button.dart';
import 'package:passenger_app/features/request_driver/viewmodel/request_driver_viewmodel.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/widgets/custom_circular_button.dart';
import 'package:passenger_app/shared/widgets/search_locations_bottom_sheet.dart';
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

class _RequestDriverBottomSheetState extends State<RequestDriverBottomSheet>
    with SingleTickerProviderStateMixin {
  final bool estimatedtime = false;
  int selectedIndex = 1; // Tracks the currently selected button index
  final List<Map> imagePaths = [
    {'path': 'assets/img/delivery.png', 'title': 'Encomiendas'},
    {'path': 'assets/img/car.png', 'title': 'Carreras'},
  ];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                ),
              ]),
          // height: 320,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            child: Column(
              children: [
                //Delivery, Ride Options
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
                //Devider line
                const Divider(color: Colors.blue),
                //REQUEST RIDE OPTIONS
                // TabBar at the top of the Bottom Sheet
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  labelStyle: const TextStyle(fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontSize: 10),
                  tabs: const [
                    Tab(text: 'Por mapa'),
                    Tab(text: 'Por micrófono'),
                    Tab(text: 'Por texto'),
                  ],
                ),
                // TabBarView below the TabBar
                SizedBox(
                  height: 290, // Set a fixed height
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      byMapOptions(sharedViewModel, requestDriverViewModel,
                          referenceTextController),
                      buildRequestDriverByAudio(),
                      buildRequestDriverByText(() {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

//Request driver by selecting pick-up and drop-off location
  Widget byMapOptions(
      SharedProvider sharedViewModel,
      RequestDriverViewModel requestDriverViewModel,
      TextEditingController referenceTextController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
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
              size: 20,
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
          const SizedBox(height: 5),

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
                    size: 20,
                    color: Colors.black54,
                  )
                : const Icon(
                    Ionicons.location,
                    size: 20,
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
          const SizedBox(height: 5),
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
                    Text("Tiempo de viaje ~ ${sharedViewModel.duration}"),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 5),
          // CustomElevatedButton(
          //   onTap: () {
          //     showStarRatingsBottomSheet(context, '');
          //   },
          //   child: const Text("Test rating stars"),
          // ),
          BSTextField(
            textEditingController: referenceTextController,
            hintText: "Referencia....",
            leftIcon: Ionicons.reader,
            rightIcon: Ionicons.pencil,
          ),
          const SizedBox(height: 5),

          //Request Taxi
          CustomElevatedButton(
            onTap: sharedViewModel.polylineFromPickUpToDropOff.points.isNotEmpty
                ? () => requestDriverViewModel.requestTaxi(
                    context, sharedViewModel, RequestType.byCoordinates)
                : null,
            child: const Text("Solicitar taxi"),
          ),
        ],
      ),
    );
  }
}
