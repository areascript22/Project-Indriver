import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:passenger_app/core/utils/dialog_util.dart';
import 'package:passenger_app/features/auth/view/pages/auth_wrapper.dart';
import 'package:passenger_app/features/home/repositories/home_services.dart';
import 'package:passenger_app/features/profile/view/pages/edit_profile_page.dart';
import 'package:passenger_app/features/ride_history/repository/pages/ride_history_page.dart';
import 'package:passenger_app/shared/models/g_user.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedViewModel = Provider.of<SharedProvider>(context, listen: false);
    GUser? passenger = sharedViewModel.passenger;

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                //Header
                const SizedBox(height: 20),
                //UserData
                if (passenger != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //image
                          UserAvatar(
                            imageUrl: passenger.profilePicture,
                          ),

                          //Passenger info
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Passenger's name

                              Text(
                                passenger.name,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Color(0xFFFDA503),
                                  ),
                                  Text("4,5")
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ));
                          },
                          icon: const Icon(Ionicons.chevron_forward))
                    ],
                  ),

                const SizedBox(height: 20),

                //Perfil
                ListTile(
                  leading: const Icon(Ionicons.time_outline),
                  title: const Text(
                    "Historial de solicitudes",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RideHistoryPage(),
                        ));
                  },
                ),

                //COnfiguración
                ListTile(
                  leading: const Icon(Ionicons.settings_outline),
                  title: const Text(
                    "Configuración",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Ionicons.information_circle_outline),
                  title: const Text(
                    "Ayuda",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Ionicons.chatbubbles_outline),
                  title: const Text("Soporte"),
                  onTap: () {},
                ),
              ],
            ),

            //Cerrar ceson
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                "Cerrar Sesión",
                style: TextStyle(fontSize: 17),
              ),
              onTap: () => DialogUtil.messageDialog(
                  context: context,
                  onAccept: () async {
                    await HomeServices.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthWrapper(),
                          ),
                          (route) => false);
                    }
                  },
                  onCancel: () {
                    Navigator.pop(context);
                  },
                  content: const Text("¿Esta seguro de cerrar seción?")),
            ),
          ],
        ),
      ),
    );
  }
}
