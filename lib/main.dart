import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart'; // debug
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minipro/Theme/menucolor.dart';
//import 'package:get_it/get_it.dart';
import 'package:minipro/authentication/authprovider.dart';
import 'package:minipro/Theme/theme.dart';
import 'package:minipro/splashscreen.dart';
import 'package:provider/provider.dart';

/*final GetIt getIt = GetIt.instance;
void setupLocator() {
  getIt.registerLazySingleton<AnalyticService>(() => AnalyticService());
}*/

void main() async {
  //debugPaintSizeEnabled = true;
  //bool loggedIn = await isLoggedIn();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
      );
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (context) => Menucolor(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Authprovider()),
        ChangeNotifierProvider(create: (_) => Menucolor()),
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
