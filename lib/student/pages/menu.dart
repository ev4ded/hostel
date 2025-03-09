import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/Student_queries/queries.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/menuColor.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Menucolor menucolor = Menucolor();
  late Color iconC;
  late Color menuC; //123, 114, 218
  late Color innerC;
  late Color text;
  List<String>? breakfast;
  List<String>? lunch;
  List<String>? snacks;
  List<String>? dinner;
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    iconC = menucolor.currentTheme["iconC"]!;
    menuC = menucolor.currentTheme["menuC"]!;
    innerC = menucolor.currentTheme["innerC"]!;
    text = menucolor.currentTheme["text"]!;
    loadMenu();
  }

  void loadMenu() async {
    try {
      if (breakfast != null && lunch != null && dinner != null) {
        setState(() {
          isloading = false;
        });
      }
      setState(() {
        isloading = true;
      });
      Map<String, dynamic>? cachedUserData =
          await _firestoreService.getCachedUserData();
      if (cachedUserData!["hostelId"] == null) {
        _showSnackBar("Hostel Id missing", isError: true);
        return;
      }
      Map<String, List<String>> menu =
          await getMenu(cachedUserData["hostelId"]);
      if (menu.isNotEmpty) {
        setState(() {
          breakfast = menu["breakfast"];
          lunch = menu["lunch"];
          dinner = menu["dinner"];
          snacks = menu["snacks"];
          isloading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to load menu:$e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double heightMainContainer = height * 0.75;
    //var breakfast = ["A", "B", "C"];
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Soup of the Day:",
            style: GoogleFonts.raleway(
              textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: isloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Center(
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: 4, bottom: 4, left: 4, right: 4),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            //main container
                            width: width * 0.95,
                            height: heightMainContainer,
                            decoration: BoxDecoration(
                                color: menuC,
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          Container(
                            //smaller container at back
                            height: 150,
                            width: width * 0.95,
                            color: Color.fromRGBO(120, 47, 32, 1),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: heightMainContainer - 30,
                            ),
                            //front most container
                            //height: heightMainContainer - 30,
                            width: width * 0.89,
                            decoration: BoxDecoration(
                              color: innerC,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Wrap(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      height: height * 0.02,
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Text(
                                                    "Breakfast:",
                                                    style:
                                                        GoogleFonts.luckiestGuy(
                                                      textStyle: TextStyle(
                                                          fontSize: 18,
                                                          //fontWeight: FontWeight.bold,
                                                          color: text),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children:
                                                      breakfast!.map((item) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10, top: 5),
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth:
                                                                    width *
                                                                        0.5),
                                                        child: Wrap(
                                                          children: [
                                                            Text(
                                                              item,
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .zcoolQingKeHuangYou(
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: text,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/breakfast1.png"),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/lunch.png"),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  "Lunch:",
                                                  style:
                                                      GoogleFonts.luckiestGuy(
                                                    textStyle: TextStyle(
                                                        fontSize: 18,
                                                        //fontWeight: FontWeight.bold,
                                                        color: text),
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: lunch!.map(
                                                    (item) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                top: 5),
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxWidth:
                                                                      width *
                                                                          0.5),
                                                          child: Wrap(
                                                            children: [
                                                              Text(
                                                                item,
                                                                softWrap: true,
                                                                style: GoogleFonts
                                                                    .zcoolQingKeHuangYou(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: text,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).toList(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: height * 0.02),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Snacks:",
                                                    style:
                                                        GoogleFonts.luckiestGuy(
                                                      textStyle: TextStyle(
                                                          fontSize: 18,
                                                          //fontWeight: FontWeight.bold,
                                                          color: text),
                                                    ),
                                                  ),
                                                  Column(
                                                    children:
                                                        snacks!.map((item) {
                                                      return Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth:
                                                                    width *
                                                                        0.5),
                                                        child: Wrap(
                                                          children: [
                                                            Text(
                                                              item,
                                                              softWrap: true,
                                                              style: GoogleFonts
                                                                  .zcoolQingKeHuangYou(
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: text,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: Image(
                                                  image: AssetImage(
                                                      "assets/images/snacks.png"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: Image(
                                                image: AssetImage(
                                                    "assets/images/dinner.png"),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Dinner:",
                                                  style:
                                                      GoogleFonts.luckiestGuy(
                                                    textStyle: TextStyle(
                                                        fontSize: 18,
                                                        //fontWeight: FontWeight.bold,
                                                        color: text),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  child: Column(
                                                    children:
                                                        dinner!.map((item) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                top: 5),
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxWidth:
                                                                      width *
                                                                          0.5),
                                                          child: Wrap(
                                                            children: [
                                                              Text(
                                                                item,
                                                                softWrap: true,
                                                                style: GoogleFonts
                                                                    .zcoolQingKeHuangYou(
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: text,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                /*SizedBox(
                                      height: 15,
                                    ),*/
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
