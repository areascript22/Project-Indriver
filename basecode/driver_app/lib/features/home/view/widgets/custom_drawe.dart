import 'package:driver_app/core/utils/dialog/dialog_util.dart';
import 'package:driver_app/features/auth/repository/auth_service.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //User data banner
                const SizedBox(height: 50),
                if (sharedProvider.driverModel != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: sharedProvider
                                      .driverModel!.profilePicture.isNotEmpty
                                  ? FadeInImage.assetNetwork(
                                      placeholder: 'assets/img/no_image.png',
                                      image: sharedProvider
                                          .driverModel!.profilePicture,
                                      fadeInDuration:
                                          const Duration(milliseconds: 50),
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    )
                                  : Image.asset(
                                      'assets/img/default_profile.png',
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Passenger's name
                              if (sharedProvider.driverModel != null)
                                Text(
                                  sharedProvider.driverModel!.name,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
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
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => const EditProfilePage(),
                            //     ));
                          },
                          icon: const Icon(Ionicons.chevron_forward))
                    ],
                  ),
                //Configuración
                ListTile(
                  leading: const Icon(Ionicons.settings),
                  title: const Text("Configuración"),
                  onTap: () {},
                ),
                //Trips history
                ListTile(
                  leading: const Icon(Ionicons.car),
                  title: const Text("Historial de viajes"),
                  onTap: () {},
                ),
                //Help for driver
                ListTile(
                  leading: const Icon(Ionicons.help),
                  title: const Text("Ayuda"),
                  onTap: () {},
                ),
              ],
            ),
            //Sing Out
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: const Text("Cerrar sesion"),
                onTap: () {
                  DialogUtil.messageDialog(
                      context: context,
                      onAccept: () async {
                        AuthService auth = AuthService();
                        await auth.signOut();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                      title: "¿Desea cerrar sesión?");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
