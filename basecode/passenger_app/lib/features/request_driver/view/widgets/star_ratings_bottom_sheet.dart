import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:passenger_app/features/request_driver/viewmodel/request_driver_viewmodel.dart';
import 'package:provider/provider.dart';

class StarRatingsBottomSheet extends StatelessWidget {
  final String driverId;
  const StarRatingsBottomSheet({super.key, required this.driverId,});

  @override
  Widget build(BuildContext context) {
    final requestDriverViewModel = Provider.of<RequestDriverViewModel>(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            'Califique su viaje',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) async {
              requestDriverViewModel.updateDriverStarRatings(
                  rating, driverId, context);
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Omitir',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showStarRatingsBottomSheet(BuildContext context, String driverId) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return  StarRatingsBottomSheet(driverId: driverId,);
    },
  );
}
