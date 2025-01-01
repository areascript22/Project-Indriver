import 'package:flutter/material.dart';
import 'package:passenger_app/features/home/viewmodel/home_view_model.dart';

class LocationServicesDisabled extends StatelessWidget {
  const LocationServicesDisabled({
    super.key,
    required this.homeViewModel,
    required this.onTap,
  });

  final HomeViewModel homeViewModel;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.redAccent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(3),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off,
                color: Colors.white,
                size: 20,
              ),
              Text(
                "Servicios de ubicación desactivados.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Click aquí para activarlos",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
