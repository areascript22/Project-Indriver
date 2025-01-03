import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/features/profile/repositories/profile_services.dart';
import 'package:passenger_app/shared/models/passenger_model.dart';
import 'package:passenger_app/shared/providers/shared_provider.dart';

class ProfileViewModel extends ChangeNotifier{
  final Logger logger = Logger();
  int currentIndexStack = 0;
  bool _loading = false;

  //For EditProfilePage
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool _selectedImage = false;
  bool _showImageSelectError = false;

  //GETTERS
  bool get selectedImage => _selectedImage;
  bool get loading => _loading;
  bool get showImageSelectError => _showImageSelectError;

  //SETTERS
  set selectedImage(bool value) {
    _selectedImage = value;
    notifyListeners();
  }

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set showImageSelectError(bool value) {
    _showImageSelectError = value;
    notifyListeners();
  }

  //Update Passenger data in Firestore
  void updatePassengerData(
      GlobalKey<FormState> formKey,
      BuildContext context,
      PassengerModel passengerModel,
      File? imageFile,
      SharedProvider sharedProvider) async {
    loading = false;
    //check if there is an image selected, otherwise we return
    if (imageFile == null && passengerModel.profilePicture.isEmpty) {
      showImageSelectError = true;
      logger.i("imagen $imageFile   ${passengerModel.profilePicture}");
    } else {
      logger.i("No imagen");
      showImageSelectError = false;
    }

    if (showImageSelectError) {
      return;
    }
    //Check form fields
    if (formKey.currentState?.validate() ?? false) {
      loading = true;
      //upnload image
      String? profilePicture = '';
      if (imageFile != null) {
        //Upload new image
        profilePicture = await ProfielServices.uploadImage(
            imageFile, FirebaseAuth.instance.currentUser!.uid);

        sharedProvider.passengerModel!.profilePicture = profilePicture!;
      }
      //add data to update
      Map<String, dynamic> valuesToUpdate = {};
      valuesToUpdate['id'] = FirebaseAuth.instance.currentUser!.uid;
      if (profilePicture.isNotEmpty) {
        valuesToUpdate['profilePicture'] = profilePicture;
      }
      if (nameController.text != passengerModel.name) {
        valuesToUpdate['name'] = nameController.text;
      }
      if (lastnameController.text != passengerModel.lastName) {
        valuesToUpdate['lastName'] = lastnameController.text;
      }
      if (phoneController.text != passengerModel.phone) {
        valuesToUpdate['phone'] = phoneController.text;
      }

      //Update data in firestore
      bool dataUpdated =
          await ProfielServices.updatePassengerDataInFirestore(valuesToUpdate);

      //Navigato to Map Page
      if (dataUpdated) {
        sharedProvider.passengerModel!.name = nameController.text;
        sharedProvider.passengerModel!.lastName = lastnameController.text;
        sharedProvider.passengerModel!.phone = phoneController.text;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos actualizados'), // Message to display
            ),
          );

          Navigator.pop(context);
        }
      }

      loading = false;
    }
  }
}