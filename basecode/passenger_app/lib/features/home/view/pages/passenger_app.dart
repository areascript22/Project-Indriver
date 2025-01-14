import 'package:flutter/material.dart';
import 'package:passenger_app/features/home/view/widgets/card_current_location_essue.dart';
import 'package:passenger_app/features/home/view/widgets/card_location_servicess_disabled.dart';
import 'package:passenger_app/features/home/view/widgets/custom_drawer.dart';
import 'package:passenger_app/features/home/viewmodel/home_view_model.dart';
import 'package:passenger_app/features/map/view/pages/map_page.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:provider/provider.dart';

class PassengerApp extends StatefulWidget {
  const PassengerApp({super.key});

  @override
  State<PassengerApp> createState() => _PassengerAppState();
}

class _PassengerAppState extends State<PassengerApp> {
  @override
  void initState() {
    super.initState();
    setDriverValue();
    checkGpsPermissions();
  }

  void setDriverValue() {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.passenger =
        Provider.of<SharedProvider>(context, listen: false).passengerModel;
  }

  void checkGpsPermissions() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    await homeViewModel.checkGpsPermissions();
    homeViewModel.listenToLocationServicesAtSystemLevel();
    homeViewModel.startLocationTracking();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (sharedProvider.deliveryLookingForDriver)
            TextButton(
                onPressed: () {
                  sharedProvider.deliveryLookingForDriver = false;
                },
                child: Text(
                  "Cancelar",
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
        ],
        // bottom: PreferredSize(
        //   preferredSize:
        //       const Size.fromHeight(1.0), // Thin line with shadow height
        //   child: Container(
        //     height: 2.0, // Line thickness
        //     decoration: BoxDecoration(
        //       color: Colors.grey[300], // Line color (light gray)
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.1),
        //           blurRadius: 1,
        //           offset: const Offset(0, 1.5),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          //Content
          const IndexedStack(
            index: 0,
            children: [
              MapPage(),
            ],
          ),
          //We can not find you on the map
          if (!homeViewModel.isCurrentLocationAvailable)
            Positioned(
              top: 90,
              right: 0,
              left: 0,
              child: CardCurrentLocationEssue(
                homeViewModel: homeViewModel,
                onTap: () {},
              ),
            ),

          //Mesages (Lcoations, Services)
          if (!homeViewModel.locationPermissionsSystemLevel)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: LocationServicesDisabled(
                homeViewModel: homeViewModel,
                onTap: () async =>
                    await homeViewModel.requestLocationServiceSystemLevel(),
              ),
            ),
          //Mesages (Lcoations, Services)
          if (!homeViewModel.locationPermissionUserLevel)
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: LocationServicesDisabled(
                homeViewModel: homeViewModel,
                onTap: () async =>
                    await homeViewModel.requestPermissionsAtUserLevel(),
              ),
            ),
        ],
      ),
    );
  }
}
