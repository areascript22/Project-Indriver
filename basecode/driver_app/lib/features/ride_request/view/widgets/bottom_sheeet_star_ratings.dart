import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RideStarRating extends StatelessWidget {
  final String driverId;
  const RideStarRating({
    super.key,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            'Califique al cliente',
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
            onRatingUpdate: (rating) async {},
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

void showRideStarRatingsBottomSheet(BuildContext context, String driverId) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return RideStarRating(
        driverId: driverId,
      );
    },
  );
}
