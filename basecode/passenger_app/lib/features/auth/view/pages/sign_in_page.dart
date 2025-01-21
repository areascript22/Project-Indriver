import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/core/utils/dialog_util.dart';
import 'package:passenger_app/core/utils/toast_message_util.dart';
import 'package:passenger_app/features/auth/view/pages/verification_page.dart';
import 'package:passenger_app/shared/widgets/custom_elevated_button.dart';
import 'package:passenger_app/features/auth/view/widgets/phone_number_field.dart';
import 'package:passenger_app/features/auth/viewmodel/passenger_viewmodel.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  //Text controller for number
  final Logger _logger = Logger();
  final TextEditingController textController = TextEditingController();
  bool isloading = false;
  bool showAlertMessage = false;

  @override
  void initState() {
    super.initState();
    textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    showAlertMessage = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final passengerViewModel = Provider.of<PassengerViewModel>(context);

    //Enviar codigo de verificacion
    void onTap() async {
      setState(() {
        isloading = true;
      });
      await FirebaseAuth.instance
          .verifyPhoneNumber(
        timeout: const Duration(seconds: 60),
        phoneNumber: "+593${textController.text}",
        verificationCompleted: (phoneAuthCredential) {},
        verificationFailed: (error) {
          ToastMessageUtil.showToast(
              "Tiempo de espera de red agotado. Por favor intente de nuevo.");

          _logger.i(error.toString());
          isloading = false;
          setState(() {});
        },
        codeSent: (verificationId, forceResendingToken) {
          //Navegamos a la pantallad e verificacion del codigo sms
          setState(() {
            isloading = false;
          });
          passengerViewModel.phoneNumber = textController.text;
          passengerViewModel.verificationId = verificationId;
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VerificationPage(),
              ));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _logger.i("Auto Retrieval Timeout.. $verificationId");
        },
      )
          .timeout(
        const Duration(seconds: 7),
        onTimeout: () {
          ToastMessageUtil.showToast(
              "Tiempo de espera de red agotado. Por favor intente de nuevo.");
        },
      );
    }

    void confirmSendSMS() {
      //Quitamos el 0 inicial del numero si es que lo tiene
      String text = textController.text;
      if (text.startsWith('0')) {
        textController.text = text.substring(1);
      }
      if (textController.text.length != 9) {
        setState(() {
          showAlertMessage = true;
        });
      } else {
        DialogUtil.messageDialog(
          onAccept: () {
            //Send SMS
            onTap();
            Navigator.pop(context);
          },
          onCancel: () {
            //Pop the Dialog Util
            Navigator.pop(context);
          },
          content: Column(
            children: [
              const Text(
                "Se enviará un SMS al siguiente número",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              Text("+593${textController.text}"),
            ],
          ),
          context: context,
        );
        return;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Image.asset("assets/img/logo.png"),

                //Titulo
                const Text(
                  "Introduce tu número de teléfono",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Te enviaremos un código para verificar tu número de telefono",
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 60),

                //TextField
                PhoneNumberField(
                  textController: textController,
                ),

                if (showAlertMessage)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Ingrese un número válido",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
                //Boton enviar
                CustomElevatedButton(
                  onTap: confirmSendSMS,
                  child: isloading
                      ? const CircularProgressIndicator()
                      : const Text("Enviar código"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
