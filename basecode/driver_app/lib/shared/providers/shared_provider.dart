import 'package:driver_app/shared/models/driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:image/image.dart' as img;

class SharedProvider extends ChangeNotifier {
  Driver? driverModel; //To user PassengerModel data across multiple Features
  bool isGPSPermissionsEnabled = false;
  Position? driverCurrentPosition;
  String? rideRequestmodel;


 


  //BOTTOM SHEET: It displays all available maps
  Future<void> showAllAvailableMaps(
      BuildContext context, Coords destination) async {
    //Get all maps installed
    final availableMaps = await MapLauncher.installedMaps;
    if (!context.mounted) {
      return;
    }
    //Show all map apps options
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //title
              const SizedBox(height: 15),
              //List of available maps
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable internal scrolling
                itemCount: availableMaps
                    .length, // Adjust this number based on your data
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      availableMaps[index].showMarker(
                          coords: destination, title: "Destination");
                    },
                    leading: SvgPicture.asset(
                      availableMaps[index].icon, // Path to the SVG icon
                      width: 40.0,
                      height: 40.0,
                    ),
                    title: Text(
                        availableMaps[index].mapName), // Your item content here
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Convert an image from asset into BitmapDescription
  Future<BitmapDescriptor?> convertImageToBitmapDescriptor(String path) async {
    try {
      final ByteData byteData = await rootBundle.load(path);
      final Uint8List bytes = byteData.buffer.asUint8List();
      img.Image originalImage = img.decodeImage(bytes)!;
      img.Image resizedImage =
          img.copyResize(originalImage, width: 100, height: 100);
      final Uint8List resizedBytes =
          Uint8List.fromList(img.encodePng(resizedImage));
      final BitmapDescriptor icon = BitmapDescriptor.fromBytes(resizedBytes);
      return icon;
    } catch (e) {
      return null;
    }
  }
}
