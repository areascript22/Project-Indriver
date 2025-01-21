import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/shared/widgets/custom_elevated_button.dart';
import 'package:passenger_app/shared/widgets/custom_testfield.dart';
import 'package:passenger_app/features/auth/viewmodel/passenger_viewmodel.dart';
import 'package:provider/provider.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final Logger logger = Logger();
  final TextEditingController textController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final passengerViewModel = Provider.of<PassengerViewModel>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              //Titulo
              const Text(
                "Ingresa el código",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              //Texfiel de verificacion
              CustomTextField(
                isKeyboardNumber: true,
                hintText: 'Código sms',
                textEditingController: textController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su contraseña'; // Required validation
                  }
                  return null; // Return null if validation passes
                },
              ),
              const SizedBox(height: 20),
              //Boton Verificar
              CustomElevatedButton(
                  onTap: () => passengerViewModel.verifySms(
                      textController.text, context),
                  child: passengerViewModel.loading
                      ? const CircularProgressIndicator()
                      : const Text("Verificar")),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
