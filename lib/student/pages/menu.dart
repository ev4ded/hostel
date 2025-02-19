import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/pages/shop.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    //var breakfast = ["A", "B", "C"];
    Color iconC = Color.fromRGBO(159, 147, 228, 1);
    Color menuC = Color.fromARGB(255, 251, 227, 199);
    Color text = Color.fromRGBO(120, 47, 32, 1);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Soup of the Day:",
            style: GoogleFonts.raleway(
                textStyle:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
        body: SingleChildScrollView(
            child: Center(
                child: Padding(
          padding: EdgeInsets.only(top: 40, bottom: 40, left: 8, right: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: width * 0.9,
                height: height * 0.7,
                decoration: BoxDecoration(
                    color: menuC, borderRadius: BorderRadius.circular(25)),
              ),
              Container(
                height: height * 0.13,
                width: width * 0.9,
                color: Color.fromRGBO(120, 47, 32, 1),
              ),
              Container(
                height: height * 0.63,
                width: width * 0.8,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(212, 184, 150, 1),
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
                        child: Text(
                          "Breakfast:",
                          style: GoogleFonts.luckiestGuy(
                            textStyle: TextStyle(
                                fontSize: 25,
                                //fontWeight: FontWeight.bold,
                                color: text),
                          ),
                        ),
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
                    Padding(
                      //dinner
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Lunch:",
                          style: GoogleFonts.luckiestGuy(
                            textStyle: TextStyle(
                                fontSize: 25,
                                //fontWeight: FontWeight.bold,
                                color: text),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "rice and curry",
                          style: GoogleFonts.zcoolQingKeHuangYou(
                            textStyle: TextStyle(
                              fontSize: 20,
                              color: text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      //lunch
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Dinner:",
                          style: GoogleFonts.luckiestGuy(
                            textStyle: TextStyle(
                              fontSize: 25,
                              color: text,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Mixed Noodles and chilli chicken",
                          style: GoogleFonts.zcoolQingKeHuangYou(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ))));
  }
}
