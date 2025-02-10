import 'package:flutter/material.dart';
import 'package:passenger_app/shared/models/driver_model.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';
import 'package:passenger_app/shared/util/shared_util.dart';
import 'package:passenger_app/shared/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

class DriverHasPackageBottomSheet extends StatefulWidget {
  const DriverHasPackageBottomSheet({
    super.key,
  });

  @override
  State<DriverHasPackageBottomSheet> createState() =>
      _DriverHasPackageBottomSheetState();
}

class _DriverHasPackageBottomSheetState
    extends State<DriverHasPackageBottomSheet> {
  final sharedUtil = SharedUtil();
  @override
  void initState() {
    super.initState();
    initializePage();
  }

  void initializePage() async {
    await sharedUtil.makePhoneVibrate();
  }

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    final DriverModel? driverModel = sharedProvider.driverModel;

    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (driverModel != null)
              Column(
                children: [
                  //Message "I have arrived"
                  Text(
                    '${driverModel.name} ha recogido su pedido.',
                    style: const TextStyle(fontSize: 18),
                  ),
                  //Vehicle model
                  Text(
                    driverModel.vehicleModel,
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),

            //BUTTON: Ready, on the way
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Aceptar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showDriverHasPackageBotttomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isDismissible: false, // Prevents dismiss by tapping outside
    enableDrag: false, // Prevents dismiss by swiping down
    isScrollControlled: true,
    builder: (BuildContext context) {
      // Wrapping bottom sheet content in WillPopScope
      return const DriverHasPackageBottomSheet();
    },
  );
}
