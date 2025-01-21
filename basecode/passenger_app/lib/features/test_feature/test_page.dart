import 'package:flutter/material.dart';
import 'package:passenger_app/features/test_feature/bottom_sheet.dart';

class TestPage2 extends StatelessWidget {
  const TestPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showRequestBottomSheet(context);
          },
          child: Text("open"),
        ),
      ),
    );
  }
}
