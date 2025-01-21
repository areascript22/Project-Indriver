import 'package:flutter/material.dart';
import 'package:passenger_app/features/home/view/widgets/servicess_issue_alert.dart';
import 'package:passenger_app/features/home/viewmodel/home_view_model.dart';
import 'package:passenger_app/features/map/view/pages/map_page.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/widgets/custom_drawer.dart';
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
       final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    await homeViewModel.checkGpsPermissions(sharedProvider);
    homeViewModel.listenToLocationServicesAtSystemLevel();
    // homeViewModel.startLocationTracking();
  }

  @override
  Widget build(BuildContext context) {
//     final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Scaffold(
      drawer: const CustomDrawer(),
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
        toolbarHeight: 0,
        bottom: homeViewModel.getIssueBassedOnPriority() != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60.0),
                child: ServicesIssueAlert(
                  dataMap: homeViewModel.getIssueBassedOnPriority()!,
                ),
              )
            : null,
      ),
      body: const Stack(
        children: [
          //Content
          IndexedStack(
            index: 0,
            children: [
              MapPage(),
            ],
          ),
        ],
      ),
    );
  }
}
