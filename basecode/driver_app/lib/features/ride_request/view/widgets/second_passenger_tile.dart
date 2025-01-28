import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:flutter/material.dart';

class SecondPassengerTile extends StatelessWidget {
  final PassengerInformation secondPassengerInfo;
  const SecondPassengerTile({
    super.key,
    required this.secondPassengerInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //profile picture
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                child: ClipOval(
                  child: secondPassengerInfo.profilePicture.isEmpty
                      ? const Icon(Icons.person,
                          color: Colors.white, size: 24.0)
                      : FadeInImage.assetNetwork(
                          placeholder: 'assets/img/default_profile.png',
                          image: secondPassengerInfo.profilePicture,
                          fadeInDuration: const Duration(milliseconds: 50),
                          width: 100,
                          height: 100,
                        ),
                ),
              ),
              //Name
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //name
                  Text(
                    secondPassengerInfo.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  //Reuqest type
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
