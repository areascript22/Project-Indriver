import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class TestPage1 extends StatefulWidget {
  TestPage1({super.key});

  @override
  State<TestPage1> createState() => _TestPage1State();
}

class _TestPage1State extends State<TestPage1> {
  final DatabaseReference driversRef =
      FirebaseDatabase.instance.ref('positions');

  final logger = Logger();

  //Firebase Functions
  Future<void> bookPosition(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
  // User is authenticated
} else {
  logger.e("User is not authenticated");
}
    try {
      await driversRef.push().set({
        "id": id,
        "timestamp": ServerValue.timestamp,
      }).timeout(Duration(seconds: 5)
      
      );
      logger.i("Succesfully written");
    } catch (e) {
      logger.e("Error while writting data: $e");
    }
  }

  void showCircleButtonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un puesto'),
          content: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(10, (index) {
              int number = index + 1;
              return CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue,
                child: IconButton(
                  icon: Text(
                    '$number',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () async {
                    //logger.i("Press button $number");
                    // Handle button press
                    await bookPosition(number.toString());
                  },
                ),
              );
            }),
          ),
          actions: [
            //Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    ).then((selectedNumber) {
      if (selectedNumber != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You selected number $selectedNumber'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Button Dialog'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showCircleButtonDialog(context);
          },
          child: const Text('Show Dialog'),
        ),
      ),
    );
  }
}
