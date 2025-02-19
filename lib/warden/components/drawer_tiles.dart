import 'package:flutter/material.dart';

import '../pages/settingspage.dart';



class DrawerTiles extends StatelessWidget {
  

  const DrawerTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:Text("s e t t i n g s",style:TextStyle( fontSize: 18.0)),
        
        leading: Icon(Icons.settings),
        onTap: () {
          Navigator.pop(
            context
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
          
        },
          );
  }
}