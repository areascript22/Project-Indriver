import 'package:driver_app/features/auth/repository/auth_service.dart';
import 'package:driver_app/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:driver_app/features/auth/view/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class PasswordRecoveryPage extends StatelessWidget {
  const PasswordRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailTextController = TextEditingController();
    final formKey = GlobalKey<FormState>(); // Form key for validation
    final AuthService auth = AuthService();

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Title
              const Text(
                "Recuperar contraseña",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Para continuar ingrese su correo electrónico, le enviaremos un email para reestablecer su contraseña.",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              //Email TextField
              CustomTextField(
                textEditingController: emailTextController,
                hintText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su correo electrónico'; // Required validation
                  }
                  // Email format validation
                  const emailPattern =
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                  final emailRegex = RegExp(emailPattern);
                  if (!emailRegex.hasMatch(value)) {
                    return 'Por favor, ingrese un correo electrónico válido';
                  }
                  return null; // Return null if validation passes
                },
              ),

              //Sign In Button
              const SizedBox(height: 15),
              AuthGradientButton(
                child: const Text(
                  'Recuperar',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  // Validate the form
                  if (formKey.currentState?.validate() ?? false) {
                    await auth.sendPasswordRecoveryEmail(
                        emailTextController.text, context);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
