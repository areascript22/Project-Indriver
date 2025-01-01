import 'package:flutter/material.dart';

class BSTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final IconData leftIcon;
  final IconData rightIcon;
  final void Function()? onRightIconPressed;

  const BSTextField({
    super.key,
    required this.textEditingController,
    required this.hintText,
    required this.leftIcon,
    required this.rightIcon,
    this.onRightIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[800], // Dark background color
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              leftIcon,
              color: Colors.grey[400], // Slightly lighter color for the icon
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(),
              ),
            ),
            IconButton(
              icon: Icon(
                rightIcon,
                color: Colors.grey[400], // Match color of the other icon
              ),
              onPressed: onRightIconPressed,
            ),
          ],
        ),
      ),
    );
  }
}
