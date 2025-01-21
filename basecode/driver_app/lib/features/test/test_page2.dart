import 'package:flutter/material.dart';

class TestPage2 extends StatefulWidget {
  const TestPage2({super.key});
  @override
  _TestPage2State createState() => _TestPage2State();
}

class _TestPage2State extends State<TestPage2> {
  bool hasGpsSignal = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('App Title'),
            ),
            bottom: hasGpsSignal
                ? null
                : PreferredSize(
                    preferredSize: Size.fromHeight(30.0),
                    child: Container(
                      color: Colors.red,
                      height: 30.0,
                      child: Center(
                        child: Text(
                          'NO GPS Signal',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Item $index'),
              ),
              childCount: 20,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            hasGpsSignal = !hasGpsSignal;
          });
        },
        child: Icon(Icons.gps_off),
      ),
    );
  }
}
