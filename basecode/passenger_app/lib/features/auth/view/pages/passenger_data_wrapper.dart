import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';
import 'package:passenger_app/features/auth/model/api_status_code.dart';
import 'package:passenger_app/features/auth/view/pages/create_profiel_data.dart';
import 'package:passenger_app/features/auth/viewmodel/passenger_viewmodel.dart';
import 'package:passenger_app/features/home/view/pages/passenger_app.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:provider/provider.dart';

class PassengerDataWrapper extends StatelessWidget {
  const PassengerDataWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger();
    final passengerViewModel =
        Provider.of<PassengerViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context,listen: false);
    return FutureBuilder(
      future: passengerViewModel.getAuthenticatedPassengerData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for the data
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          //Always we will get a AuthREsult object
          final authResult = snapshot.data as Succes;

          if (authResult.response is PassengerModel) {
            //The Passenger (current user) info.
            passengerViewModel.passenger =
                authResult.response as PassengerModel;
            sharedProvider.passengerModel =
                authResult.response as PassengerModel;
            logger.i("Auth result is: ${authResult.response}");
            return const PassengerApp();
          } else {
            return const CreateProfileData();
          }
        } else {
          logger.i("There is NOT info of ${snapshot.data}");
          return const CircularProgressIndicator();
        }
      },
    );
  }
}