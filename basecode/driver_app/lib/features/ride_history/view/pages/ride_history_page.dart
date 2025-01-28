import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Driver is not authenticated");
      return const Center(
        child: Text("Error: No está autenticado."),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis viajes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ride_history')
            .where('driverId', isEqualTo: driverId) // Filter by driverId
            //.orderBy('startTime', descending: true) // Order by most recent
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.blue,
            ));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching ride history'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No ride history available.'));
          }

          final rideHistoryList = snapshot.data!.docs
              .map((doc) => RideHistoryModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: rideHistoryList.length,
            itemBuilder: (context, index) {
              final ride = rideHistoryList[index];
              return RideHistoryTile(ride: ride);
            },
          );
        },
      ),
    );
  }
}

class RideHistoryTile extends StatelessWidget {
  final RideHistoryModel ride;

  RideHistoryTile({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pasajero: ${ride.passengerName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            //If It's by Coords
            if (ride.requestType == RequestType.byCoordinates)
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Ionicons.location,
                        color: Colors.green,
                      ),
                      Text(ride.pickUpLocation),
                    ],
                  ),
                  //Drop off
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Ionicons.location,
                        color: Colors.blue,
                      ),
                      Text(ride.dropOffLocation),
                    ],
                  ),
                ],
              ),

            if (ride.requestType == RequestType.byTexting)
              Container(
                padding: const EdgeInsets.all(3),
                // child: Text(ride),
              ),
            const SizedBox(height: 8),
            //Text('Distancia: ${ride.distance.toStringAsFixed(2)} km'),
            // Text('Status: ${ride.status}'),
            Text(
              'Fecha: ${formatTimestamp(ride.startTime)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     // Navigate to ride details or map
                //   },
                //   child: const Text('Detalles'),
                // ),
                Text(
                  ride.requestType,
                  style: TextStyle(
                    color: ride.requestType == 'byCoordinates'
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}
