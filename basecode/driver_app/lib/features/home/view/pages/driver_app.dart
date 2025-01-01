import 'package:driver_app/features/home/view/widgets/card_current_location_essue.dart';
import 'package:driver_app/features/home/view/widgets/location_services_disabled.dart';
import 'package:driver_app/features/map/view/pages/map_page.dart';
import 'package:driver_app/features/map/view/widgets/driver_position_dialog.dart';
import 'package:driver_app/features/purchase_request/view/pages/purchase_orders_page.dart';
import 'package:driver_app/features/home/view/widgets/custom_drawe.dart';
import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
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
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.driver = Provider.of<SharedProvider>(context, listen: false).driverModel;
  }


  void checkGpsPermissions() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    bool gpsPermissions = await homeViewModel.checkGpsPermissions();
    homeViewModel.listenToLocationServicesAtSystemLevel();
    sharedProvider.isGPSPermissionsEnabled = gpsPermissions;
    homeViewModel.startLocationTracking();
    homeViewModel.setonDisconnectHandler();
  }

  @override
  void dispose() {
    super.dispose();
    logger.i("Disposing");
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
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
          // index: homeViewModel.locationPermissionUserLevel
          //     ? homeViewModel.currentPageIndex + 1
          //     : 0,
          index: homeViewModel.currentPageIndex,
          children: const [
            // PermissionsPage(),
            MapPage(),
            PurchaseOrdersPage(),
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
              onTap: () async =>
                  await homeViewModel.requestPermissionsAtUserLevel(),
            ),
          ),
      ]),
      bottomNavigationBar: homeViewModel.locationPermissionsSystemLevel
          ? BottomNavigationBar(
              currentIndex: homeViewModel.currentPageIndex,
              onTap: (index) {
                homeViewModel.currentPageIndex = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Mapa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
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
