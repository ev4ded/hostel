import 'package:flutter/material.dart';
import 'package:minipro/warden/components/drawer_tiles.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(children: [
          // app logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 58.0),
            child: Icon(
              Icons.person_3_rounded,
              size: 100.0,
              //text: 'Hostel Warden',
              color: Color.fromARGB(248, 70, 70, 70),
            ),
          ),
          DrawerTiles(),
        ]),
      ),
    );
  }
}
