import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ByTextInfo extends StatelessWidget {
  const ByTextInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //title
            const Row(
              children: [
                Text(
                  "Petición ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("mediante indicaciónes en texto."),
              ],
            ),
            //Content
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(5),
              width: double.infinity,
              decoration: BoxDecoration(
                //color: const Color.fromARGB(255, 209, 226, 255),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(rideRequestViewModel.byTextIndications),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
