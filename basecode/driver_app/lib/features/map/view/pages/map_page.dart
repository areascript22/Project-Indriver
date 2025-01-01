import 'package:driver_app/features/map/view/widgets/driver_position_dialog.dart';
import 'package:driver_app/features/map/viewmodel/map_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    //Adign A value to our 
  }

  @override
  Widget build(BuildContext context) {
    final mapViewModel = Provider.of<MapViewModel>(context);
    return Scaffold(
      body: Stack(
        children: [
          //Map
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: LatLng(-3.624649, -79.237945),
              zoom: 14,
            ),
          ),
          //Button
          //BUTTON: Select Position Taxi
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
              child: mapViewModel.currenQueuePoosition == null
                  ? const Icon(
                      Ionicons.add,
                      color: Colors.white,
                      size: 30,
                    )
                  : Text(mapViewModel.currenQueuePoosition.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
