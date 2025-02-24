import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart'; // debug
import 'package:firebase_core/firebase_core.dart';
import 'package:minipro/authentication/authprovider.dart';
import 'package:minipro/student/Theme/theme.dart';
import 'package:minipro/splashscreen.dart';
import 'package:provider/provider.dart';

void main() async {
  //debugPaintSizeEnabled = true;
  //bool loggedIn = await isLoggedIn();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authprovider()),
      ],
      child: MaterialApp(
        home: Splashscreen(),
        debugShowCheckedModeBanner: false,
        //
        theme: AppThemes.lightTheme, // Light Theme
        darkTheme: AppThemes.darkTheme, // Dark Theme
        themeMode: ThemeMode.system,
      ),
    );
  }
}
