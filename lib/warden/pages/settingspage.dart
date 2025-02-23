import 'package:flutter/material.dart';
//import 'package:hostelwarden/themes/theme_provider.dart';
//import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
          children: [
            ListTile(
              title: Text("Dark Mode"),
              /*trailing: CupertinoSwitch(

            onChanged:(value) =>Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            
          )*/
            ),
          ],
        ));
  }
}
