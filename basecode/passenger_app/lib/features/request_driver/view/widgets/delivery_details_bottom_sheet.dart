import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:passenger_app/features/request_driver/view/widgets/phone_text_field.dart';
import 'package:passenger_app/shared/widgets/custom_elevated_button.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DeliveryDetailsBottomSheet extends StatefulWidget {
  const DeliveryDetailsBottomSheet({super.key});
  @override
  State<DeliveryDetailsBottomSheet> createState() =>
      _DeliveryDetailsBottomSheetState();
}

class _DeliveryDetailsBottomSheetState
    extends State<DeliveryDetailsBottomSheet> {
  final Logger logger = Logger();
  final SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  String wordsSpoken = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    // Text controllers for sender and recipient
    final senderTextController = TextEditingController();
    final recipientTextController = TextEditingController();
    final detailsTextController = TextEditingController();

    // Adjust padding for keyboard appearance
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16), // Rounded top corners
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: keyboardHeight > 0
              ? keyboardHeight
              : 10, // Adjust bottom padding based on keyboard
        ),
        child: SingleChildScrollView(
          // Allows scrolling when keyboard is up
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensures the sheet covers content size
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Detalles de la encomienda",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              // Sender's phone number
              const SizedBox(height: 8),
              PhoneTextField(
                controller: senderTextController,
                hintText: "Número del remitente",
              ),

              // Recipient's phone number
              PhoneTextField(
                controller: recipientTextController,
                hintText: "Número del destinatario",
              ),
              const SizedBox(height: 10),

              // Delivery description
              Text(
                "Describa la entrega",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),

              // TextField for delivery description
              const SizedBox(height: 10),
              TextField(
                controller: detailsTextController,
                maxLength: 200,
                maxLines: null, // Allow multiple lines
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Ejemplo: Caja de tamaño grande, frágil..",
                  filled: true,
                  fillColor: Colors.grey[200], // Background color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.grey[400]!), // Default border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey[400]!), // Border in unfocused mode
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Colors.blue), // Border in focused mode
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintStyle: TextStyle(
                    color: Colors.grey[600], // Adjust hint text color if needed
                    height:
                        1.5, // This adjusts the line height for better readability
                  ),
                ),
              ),

              // Save button
              CustomElevatedButton(onTap: () {}, child: const Text("Guardar")),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to display the bottom sheet
void showDeliveryDetailsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows controlling the height
    backgroundColor: Colors.transparent, // Transparent background
    builder: (context) {
      return const DeliveryDetailsBottomSheet();
    },
  );
}
