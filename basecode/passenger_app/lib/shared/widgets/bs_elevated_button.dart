import 'package:flutter/material.dart';


class BSElevatedButton extends StatefulWidget {
  final Widget child;
  final bool pickUpDestination;
  final Icon icon;
  final Color backgroundColor;
  final void Function()? onPressed;

  const BSElevatedButton({
    super.key,
    required this.child,
    required this.pickUpDestination,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  State<BSElevatedButton> createState() => _BSElevatedButtonState();
}

class _BSElevatedButtonState extends State<BSElevatedButton> {
  @override
  Widget build(BuildContext context) {
   // final testController = TextEditingController();
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: widget.backgroundColor,
        // backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        minimumSize: const Size(100, 55),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          widget.icon,
          const SizedBox(width: 5.0),
          widget.child,
          // Text(
          //   widget.child,
          //   style: Theme.of(context).textTheme.bodyLarge,
          //  ),
        ],
      ),
    );
  }
}
