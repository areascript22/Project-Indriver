import 'package:driver_app/features/auth/repository/auth_service.dart';
import 'package:driver_app/features/auth/view/pages/password_recovery_page.dart';
import 'package:driver_app/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:driver_app/features/auth/view/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final formKey = GlobalKey<FormState>(); // Form key for validation
  final AuthService _auth = AuthService();
  final Logger logger = Logger();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                "Iniciar Sesión",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 15),
              //password TextField
              CustomTextField(
                textEditingController: passwordTextController,
                isObscureText: true,
                hintText: 'Contraseña',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su contraseña'; // Required validation
                  }
                  if (value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres'; // Length validation
                  }
                  return null; // Return null if validation passes
                },
              ),

              //Sign In Button
              const SizedBox(height: 15),
              AuthGradientButton(
                child: !isLoading
                    ? const Text(
                        'Inisiar sesion',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      )
                    : const CircularProgressIndicator(),
                onPressed: () async {
                  // Validate the form

                  if (formKey.currentState?.validate() ?? false) {
                    setState(() {
                      isLoading = true;
                    });
                    User? user = await _auth.loginWithEmailAndPassword(
                        emailTextController.text, passwordTextController.text);
                    if (user != null) {
                      logger.e(
                          "Sending verification email : ${user.emailVerified}");

                      if (!user.emailVerified) {
                        await _auth.sendVerificationEmail(user);
                        logger.i("Email just verified....");
                      }
                    } else {
                      //Toast

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Usuario no registrado")));
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
              ),

              //Forgot password
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      //Navigate to Password recovery Page
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordRecoveryPage(),
                          ));
                    },
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
