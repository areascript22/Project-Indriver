import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final void Function()? onPressed;
  final Icon icon;
  const CircularButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .background, // Set the background color
        shape: BoxShape.circle, // Optional: make it circular
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color with opacity
            blurRadius: 6, // Spread of the shadow
            offset:
                const Offset(0, 2), // Shadow position (horizontal, vertical)
          ),
        ],
      ),
      child: IconButton(
        icon: icon,
        color: Colors.blue, // Set the icon color
        onPressed: onPressed,
      ),
    );
  }
}
