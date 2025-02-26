import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Menu',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}