import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/pages/shop.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Color iconC = Color.fromRGBO(255, 189, 109, 1);
  Color menuC = Color.fromRGBO(123, 114, 218, 1); //123, 114, 218
  Color text = Color.fromRGBO(120, 47, 32, 1);
  double heightMainContainer = 650;
  List<String>? breakfast;
  List<String>? lunch;
  List<String>? snacks;
  List<String>? dinnner;
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;

  @override
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    Map<String, dynamic>? cachedUserData =
        await _firestoreService.getCachedUserData();
    if (cachedUserData != null) {
      setState(() {
        userData = cachedUserData;
      });
    } else {
      await _firestoreService.getUserData();
      Map<String, dynamic>? newUserData =
          await _firestoreService.getCachedUserData();
      setState(() {
        userData = newUserData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    //var breakfast = ["A", "B", "C"];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Soup of the Day:",
          style: GoogleFonts.raleway(
              textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, myRoute(Shop()));
            },
            icon: Icon(
              LucideIcons.store,
              size: 25,
              color: iconC,
            ),
            color: iconC,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: width * 0.95,
                height: heightMainContainer,
                decoration: BoxDecoration(
                    color: menuC, borderRadius: BorderRadius.circular(30)),
              ),
              Container(
                height: 150,
                width: width * 0.95,
                color: Color.fromRGBO(11, 14, 29, 1),
              ),
              Container(
                height: heightMainContainer - 30,
                width: width * 0.89,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 222, 250, 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Text(
                      "MENU",
                      style: GoogleFonts.barriecito(
                        textStyle: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: text),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: width * 0.65,
                      color: text,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      //breakfast
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Breakfast:",
                                  style: GoogleFonts.luckiestGuy(
                                    textStyle: TextStyle(
                                        fontSize: 25,
                                        //fontWeight: FontWeight.bold,
                                        color: text),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  //lunch
                                  padding: const EdgeInsets.only(
                                    left: 30,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Idli & Sambar",
                                      style: GoogleFonts.zcoolQingKeHuangYou(
                                        textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: text),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: Image(
                                  image: AssetImage(
                                      "assets/images/breakfast.png")),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
