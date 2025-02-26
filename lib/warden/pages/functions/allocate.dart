import 'package:flutter/material.dart';

class RoomAllotment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Room Allotment"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Room Allotment',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}