import 'package:flutter/material.dart';

class WaitingOverlay extends StatefulWidget {
  const WaitingOverlay();
  @override
  _WaitingOverlayState createState() => _WaitingOverlayState();
}

class _WaitingOverlayState extends State<WaitingOverlay> {
  bool _isOverlayVisible = true;

  void _dismissOverlay() {
    setState(() {
      _isOverlayVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taxi App"),
      ),
      body: Stack(
        children: [
          // Main content of the screen
          Center(
            child: Text("Main content goes here."),
          ),
          // Overlay
          if (_isOverlayVisible)
            Container(
              color:
                  Colors.black.withOpacity(0.7), // Semi-transparent background
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Message
                          Text(
                            "Waiting for drivers...",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              elevation: 5,
                            ),
                            onPressed: _dismissOverlay,
                            child: Text(
                              "Dismiss",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
