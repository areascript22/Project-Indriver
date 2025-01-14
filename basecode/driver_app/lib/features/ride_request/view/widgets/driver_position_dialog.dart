import 'package:driver_app/features/ride_request/repository/ride_request_service.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DriverPositionsDialog extends StatefulWidget {
  DriverPositionsDialog({Key? key});

  @override
  State<DriverPositionsDialog> createState() => _DriverPositionsDialogState();
}

Logger logger = Logger();

class _DriverPositionsDialogState extends State<DriverPositionsDialog> {
  @override
  Widget build(BuildContext context) {
    final DatabaseReference requestsRef =
        FirebaseDatabase.instance.ref('positions');
    List<bool> circularButtonActivation = [true, true, true, true, true, true];
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escoje un puesto disponible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: requestsRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                }
                Map<String, dynamic> data = {};

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  // Cast the data to a Map for easy manipulation
                  if (snapshot.data!.snapshot.value is! String) {
                    data = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map);
                  }
                }
                // Convert Map to a List of MapEntry and sort by Timestamp
                final sortedData = data.entries.toList()
                  ..sort((a, b) {
                    final aTimestamp = a.value['Timestamp'] as int? ?? 0;
                    final bTimestamp = b.value['Timestamp'] as int? ?? 0;
                    return aTimestamp.compareTo(bTimestamp); // Ascending order
                  });

                // Print or return the sorted data
                int counter = 0;
                for (var entry in sortedData) {
                  if (entry.key == uid) {
                    rideRequestViewModel.myPosition = counter;
                  }
                  counter++;
                }

                return Column(
                  children: [
                    _buildButtonRow([0, 1, 2], circularButtonActivation,
                        rideRequestViewModel),
                    const SizedBox(height: 16),
                    _buildButtonRow([3, 4, 5], circularButtonActivation,
                        rideRequestViewModel),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: !rideRequestViewModel.driverInQueue
                  ? () async {
                      //Book a position
                      await RideRequestService.bookDriverPositionInQueue(
                          idUsuario: uid, status: true);
                      rideRequestViewModel.driverInQueue = true;
                      rideRequestViewModel.currenQueuePoosition =
                          rideRequestViewModel.myPosition;
                    }
                  : rideRequestViewModel.freeUpDriverPositionInQueue,
              child: !rideRequestViewModel.driverInQueue
                  ? const Text("Reservar puesto")
                  : const Text("Liberar puesto"),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row of buttons for the specified button numbers.
  Widget _buildButtonRow(List<int> buttonNumbers, List<bool> activations,
      RideRequestViewModel rideRequestViewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttonNumbers.map((number) {
        logger.i(
            "Current number: $number my numbre: ${rideRequestViewModel.myPosition}");
        Color color = Colors.blue;
        if (rideRequestViewModel.myPosition != null) {
          if (number ==rideRequestViewModel. myPosition && rideRequestViewModel.driverInQueue) {
            color = Colors.green;
          }
          if (number < rideRequestViewModel.myPosition!) {
            color = Colors.grey;
          }
        }

        return _buildCircularButton(number, color);
      }).toList(),
    );
  }

  /// Builds an individual circular button.
  Widget _buildCircularButton(int number, Color color) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          //padding: const EdgeInsets.all(10),
          backgroundColor: color,
        ),
        child: Text('$number'),
      ),
    );
  }
}
