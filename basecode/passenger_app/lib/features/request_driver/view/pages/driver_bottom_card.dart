import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/models/driver_model.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverBottomCard extends StatefulWidget {
  const DriverBottomCard({super.key});

  @override
  State<DriverBottomCard> createState() => _DriverBottomCardState();
}

class _DriverBottomCardState extends State<DriverBottomCard> {
  final Logger logger = Logger();
  @override
  Widget build(BuildContext context) {
    final SharedProvider provider = Provider.of<SharedProvider>(context);
    DriverModel? driverModel = provider.driverModel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          //  Expanded(
          //  child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                driverModel!.vehicleModel,
                style: Theme.of(context).textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // ),
          const SizedBox(width: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Driver infollll
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: SizedBox(
                  // color: Colors.red,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Profile Image
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: ClipOval(
                          child: driverModel.profilePicture.isEmpty
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 24.0)
                              : FadeInImage.assetNetwork(
                                  placeholder: 'assets/img/default_profile.png',
                                  image: driverModel.profilePicture,
                                  fadeInDuration:
                                      const Duration(milliseconds: 50),
                                  width: 100,
                                  height: 100,
                                ),
                        ),
                      ),
                      Text(
                        driverModel.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          Text(driverModel.rating.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SizedBox(
                  //  color: Colors.green,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          _sendSMS(driverModel.phone, "Espenrando...");
                          //showDriverArrivedBotttomSheet(context);
                        },
                        icon: const Icon(Ionicons.chatbox_ellipses_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to send SMS
  void _sendSMS(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Could not launch SMS: $smsUri';
      }
    } catch (e) {
      logger.e('Error sending SMS: $e');
    }
  }
}
