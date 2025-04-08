import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/menucolor.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/Student_queries/queries.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String breakfast = "";
  String lunch = "";
  String snacks = "";
  String dinner = "";
  bool shown = false;
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    iconC = menucolor.currentTheme["iconC"]!;
    menuC = menucolor.currentTheme["menuC"]!;
    innerC = menucolor.currentTheme["innerC"]!;
    text = menucolor.currentTheme["text"]!;
    loadMenu();
    isshown();
  }

  @override
  void dispose() {
    // Reset to allow all orientations when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void loadMenu() async {
    try {
      setState(() {
        isloading = true;
      });
      Map<String, dynamic>? cachedUserData =
          await _firestoreService.getCachedUserData();
      if (cachedUserData!["hostelId"] == null) {
        _showSnackBar("Hostel Id missing", isError: true);
        return;
      }
      Map<String, String> menu = await getMenu(cachedUserData["hostelId"]);
      if (menu.isNotEmpty) {
        setState(() {
          breakfast = menu["breakfast"] ?? "";
          lunch = menu["lunch"] ?? "";
          dinner = menu["dinner"] ?? "";
          snacks = menu["snacks"] ?? "";
          isloading = false;
        });
      } else {
        setState(() {
          isloading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Failed to load menu:$e", isError: true);
    }
  }

  Future<void> isshown() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastShownDate = prefs.getString('lastFloatingDate');
    if (lastShownDate != today) {
      setState(() {
        shown = true;
      });
      await prefs.setString('lastFloatingDate', today);
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
      body: Stack(
        children: [
          isloading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 4, bottom: 4, left: 4, right: 4),
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
                              child: (breakfast == "" ||
                                      lunch == "" ||
                                      snacks == "" ||
                                      dinner == "")
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Image(
                                              image: AssetImage(
                                                  "assets/images/missing.png")),
                                        ),
                                        SizedBox(
                                          height: 40,
                                        ),
                                        Text(
                                          "Does your hostel have no food???",
                                          softWrap: true,
                                          style: GoogleFonts.luckiestGuy(
                                              fontSize: 18, color: text),
                                        )
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Text(
                                                            "Breakfast:",
                                                            style: GoogleFonts
                                                                .luckiestGuy(
                                                              textStyle: TextStyle(
                                                                  fontSize: 18,
                                                                  //fontWeight: FontWeight.bold,
                                                                  color: text),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          breakfast,
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          style: GoogleFonts
                                                              .zcoolQingKeHuangYou(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: text,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
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
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 14),
                                                  child: SizedBox(
                                                    width: 100,
                                                    height: 100,
                                                    child: Image(
                                                      image: AssetImage(
                                                          "assets/images/lunch.png"),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        "Lunch:",
                                                        style: GoogleFonts
                                                            .luckiestGuy(
                                                          textStyle: TextStyle(
                                                              fontSize: 18,
                                                              //fontWeight: FontWeight.bold,
                                                              color: text),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          lunch,
                                                          softWrap: true,
                                                          style: GoogleFonts
                                                              .zcoolQingKeHuangYou(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: text,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: height * 0.02),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0, right: 10.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Snacks:",
                                                          style: GoogleFonts
                                                              .luckiestGuy(
                                                            textStyle: TextStyle(
                                                                fontSize: 18,
                                                                //fontWeight: FontWeight.bold,
                                                                color: text),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            snacks,
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            style: GoogleFonts
                                                                .zcoolQingKeHuangYou(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: text,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0),
                                                  child: SizedBox(
                                                    width: 100,
                                                    height: 100,
                                                    child: Image(
                                                      image: AssetImage(
                                                          "assets/images/dinner.png"),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Dinner:",
                                                        style: GoogleFonts
                                                            .luckiestGuy(
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
                                                            const EdgeInsets
                                                                .only(
                                                          right: 10,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            dinner,
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            style: GoogleFonts
                                                                .zcoolQingKeHuangYou(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: text,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          if (!shown)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: width * 0.85,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(120, 47, 32, 1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 5.0, bottom: 5, left: 8, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "DID YOU HAVE FOOD TODAY??",
                          style: GoogleFonts.inter(color: innerC),
                        ),
                        SizedBox(width: 5),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            LucideIcons.checkCircle,
                            size: 20,
                            color: Colors.green,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
