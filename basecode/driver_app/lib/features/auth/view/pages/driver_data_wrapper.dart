import 'package:driver_app/features/auth/model/api_result.dart';
import 'package:driver_app/features/auth/view/pages/no_registered_page.dart';
import 'package:driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:driver_app/features/home/view/pages/driver_app.dart';
import 'package:driver_app/shared/models/driver.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:provider/provider.dart';

class DriverDataWrapper extends StatelessWidget {
  const DriverDataWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context);

    return FutureBuilder(
      future: authViewModel.getAuthenticatedDriver(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for the data
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data is Failure) {
            var response = snapshot.data as Failure;
            logger.i(
                "Failure value: ${response.errorResponse} current use: ${FirebaseAuth.instance.currentUser!.uid}");
            return const NotRegisteredPage();
          } else {
            //Always we will get a AuthREsult object
            final authResult = snapshot.data as Succes;

            if (authResult.response is Driver) {
              //Check if Driver has 'driver' role
              Driver currentDriver = authResult.response as Driver;
              if (currentDriver.role == 'driver') {
                sharedProvider.driverModel = currentDriver;
                return const DriverApp();
              } else {
                return const CircularProgressIndicator(
                  color: Colors.red,
                );
              }
            } else {
              return const CircularProgressIndicator();
            }
          }
        } else {
          logger.i("There is NOT info of ${snapshot.data}");
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
