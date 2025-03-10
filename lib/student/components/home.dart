import 'package:flutter/material.dart';
import 'package:minipro/Theme/menucolor.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menuColorProvider = Provider.of<Menucolor>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Theme Toggle"),
        backgroundColor: menuColorProvider.currentTheme["menuC"],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select a Theme",
              style: TextStyle(
                fontSize: 20,
                color: menuColorProvider.currentTheme["text"],
              ),
            ),
            SizedBox(height: 20),
            ToggleButtons(
              isSelected: [
                menuColorProvider.selectedTheme == 0,
                menuColorProvider.selectedTheme == 1,
                menuColorProvider.selectedTheme == 2,
              ],
              selectedColor: Colors.white,
              fillColor: menuColorProvider.currentTheme["menuC"],
              onPressed: (index) {
                menuColorProvider.setTheme(index);
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Theme 1"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Theme 2"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Theme 3"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
