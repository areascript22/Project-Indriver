import 'package:driver_app/features/home/view/widgets/card_current_location_essue.dart';
import 'package:driver_app/features/home/view/widgets/location_services_disabled.dart';
import 'package:driver_app/features/ride_request/view/pages/ride_request_page.dart';
import 'package:driver_app/features/ride_request/view/widgets/driver_position_dialog.dart';
import 'package:driver_app/features/delivery_request/view/pages/delivery_request_page.dart';
import 'package:driver_app/features/home/view/widgets/custom_drawe.dart';
import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DriverApp extends StatefulWidget {
  const DriverApp({super.key});
  @override
  _DriverAppState createState() => _DriverAppState();
}

class _DriverAppState extends State<DriverApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //Firs assign value to our HomeViewModel
    setDriverValue();
    //Call ChechGPSPermissions function
    checkGpsPermissions();
  }

  void setDriverValue() {
    logger.f("");
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.driver =
        Provider.of<SharedProvider>(context, listen: false).driverModel;
  }

  void checkGpsPermissions() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    homeViewModel
        .listenToRequests(FirebaseDatabase.instance.ref('delivery_requests'));
    bool gpsPermissions =
        await homeViewModel.checkGpsPermissions(sharedProvider);
    homeViewModel.listenToLocationServicesAtSystemLevel();
    sharedProvider.isGPSPermissionsEnabled = gpsPermissions;
    homeViewModel.startLocationTracking(sharedProvider);
    homeViewModel.setOnDisconnectHandler();
  }

  @override
  void dispose() {
    super.dispose();
    logger.i("Disposing");
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {},
          child: const Text(""),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Stack(children: [
        //Content
        IndexedStack(
          index: homeViewModel.currentPageIndex,
          children: const [
            // PermissionsPage(),
            RideMRequestPage(),
            DeliveryRequestPage(),
          ],
        ),

        //We can not find you on the map
        if (!homeViewModel.isCurrentLocationAvailable)
          Positioned(
            top: 0,
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
              onTap: () async => await homeViewModel
                  .requestPermissionsAtUserLevel(sharedProvider),
            ),
          ),
      ]),
      bottomNavigationBar: homeViewModel.locationPermissionsSystemLevel
          ? BottomNavigationBar(
              currentIndex: homeViewModel.currentPageIndex,
              onTap: (index) {
                homeViewModel.currentPageIndex = index;
              },
              items: [
                //Map icon
                const BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Mapa',
                ),
                //Shpping cart icon
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(Icons.shopping_cart),
                      ),
                      if (homeViewModel.deliveryRequestLength > 0)
                        Positioned(
                          right: 0,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              homeViewModel.deliveryRequestLength.toString(),
                              style: const TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 10, // Font size for the count
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Órdenes',
                ),
              ],
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
            )
          : const SizedBox(),
    );
  }
}
