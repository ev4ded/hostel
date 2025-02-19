import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/authentication/signuppage.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/emailtextfield.dart';
import 'package:minipro/student/components/myclipper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/student/components/mysnackbar.dart';
//import 'package:minipro/components/mytextfield.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Map<String, bool> _error = {
    'email': false,
    'password': false,
  };

  bool isobscureText = true;
  void clearTextField() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      if (emailController.text.isNotEmpty) {
        setState(() {
          _error['email'] = false;
        });
      }
    });
    passwordController.addListener(() {
      if (passwordController.text.isNotEmpty) {
        setState(() {
          _error['password'] = false;
        });
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backboxColor = Color.fromRGBO(36, 39, 38, 1);
    final Color mainboxColor = Color.fromRGBO(203, 178, 182, 1);
    final Color inputtextColor = Color.fromRGBO(240, 237, 235, 1);
    final Color buttonColor = Color.fromRGBO(230, 128, 78, 1);
    //BorderRadius borderRadius = BorderRadius.circular(20);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: backboxColor,
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height,
            ),
            child: IntrinsicHeight(
              child: Stack(clipBehavior: Clip.none, children: [
                IgnorePointer(
                  child: ClipPath(
                    clipper: MyClipper(),
                    child: Container(
                      height: height * 0.6,
                      width: width,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/meow.jpg'),
                        fit: BoxFit.cover,
                      )),
                    ),
                  ),
                ),
                Positioned(
                    top: height * 0.25,
                    left: 20,
                    child: Container(
                      width: width * 0.9,
                      height: height - 370,
                      decoration: BoxDecoration(
                        color: mainboxColor, //fromRGBO(238, 158, 142, 1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 10, left: 15),
                              child: Text('Login',
                                  style: GoogleFonts.teko(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0, left: 8, right: 8),
                              child: Emailtextfield(
                                bgColor: inputtextColor,
                                hinttext: 'EMAIL',
                                borderWidth: 1,
                                controller: emailController,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0, left: 8, right: 8),
                              child: TextField(
                                style: TextStyle(color: Colors.black),
                                controller: passwordController,
                                obscureText: isobscureText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: inputtextColor,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isobscureText =
                                            !isobscureText; //toggle password icon
                                      });
                                    },
                                    icon: Icon(isobscureText
                                        ? Ionicons.eye_sharp
                                        : Ionicons.eye_off_sharp),
                                  ),
                                  hintText: 'PASSWORD',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      width: 1.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 15.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    print('forhot');
                                  },
                                  child: Text(
                                    "forgot your password?",
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: width * 0.9,
                                  height: height * 0.06,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all(buttonColor),
                                    ),
                                    onPressed: () {
                                      _validateInput();
                                      login();
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Dont have a account?"),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          myRoute(SignupPage()),
                                        );
                                      },
                                      child: Text(
                                        "SignUp",
                                        style:
                                            TextStyle(color: Colors.blueAccent),
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ))
              ]),
            ),
          ),
        ));
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }
    try {
      final UserCredential user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      await FirestoreServices().getUserData();
      await FirestoreServices().getUserRole();
      if (!mounted) return;
      saveLoginState(true);
      _showSnackBar("login successful!!");
      Navigator.pushAndRemoveUntil(
          context, myRoute(Splashscreen()), (route) => false);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Signup failed: ${e.toString()}');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }

  void _validateInput() {
    if (emailController.text.isEmpty) {
      setState(() {
        _error['email'] = true;
      });
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        _error['password'] = true;
      });
    }
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}
