import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void showRequestBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return DynamicRequestOptions();
    },
  );
}

class DynamicRequestOptions extends StatefulWidget {
  @override
  _DynamicRequestOptionsState createState() => _DynamicRequestOptionsState();
}

class _DynamicRequestOptionsState extends State<DynamicRequestOptions> {
  int selectedOption = 0; // 0: Microphone, 1: Text, 2: Map

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Make a Request",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "Choose how you want to make your request",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Options Row (Microphone, Text, Map)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOptionButton(
                  icon: Icons.mic, label: "Microphone", index: 0),
              _buildOptionButton(
                  icon: Icons.text_fields, label: "Text", index: 1),
              _buildOptionButton(icon: Icons.map, label: "Map", index: 2),
            ],
          ),
          SizedBox(height: 20),

          // Dynamic Content
          Expanded(child: _buildDynamicContent(selectedOption)),

          // Confirm Button
          ElevatedButton(
            onPressed: () {
              // Submit action
            },
            child: Center(
              child: Text("Submit Request"),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
      {required IconData icon, required String label, required int index}) {
    return GestureDetector(
      onTap: () => setState(() => selectedOption = index),
      child: Column(
        children: [
          Icon(icon,
              size: 20,
              color: selectedOption == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey),
          SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: selectedOption == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              )),
        ],
      ),
    );
  }

  Widget _buildDynamicContent(int option) {
    switch (option) {
      case 0:
        return _microphoneContent();
      case 1:
        return _textContent();
      case 2:
        return _mapContent();
      default:
        return Container();
    }
  }

  Widget _microphoneContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mic, size: 60, color: Colors.blue),
        const SizedBox(height: 16),
       const  Text(
          "Tap the microphone to start speaking",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Start recording action
          },
          child: Text("Start Listening"),
        ),
      ],
    );
  }

  Widget _textContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: "Enter your request",
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                // Clear text field
              },
            ),
          ),
        ),
        SizedBox(height: 16),
        Text("Suggestions: (e.g., '123 Main Street')",
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _mapContent() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // Default location
              zoom: 14,
            ),
            onTap: (LatLng position) {
              // Add pin to selected location
            },
          ),
        ),
        SizedBox(height: 16),
        Text(
          "Tap on the map to select a location",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
