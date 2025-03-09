import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipro/authentication/fcmtoken.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/authentication/signuppage.dart';
import 'package:minipro/Theme/appcolors.dart';
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: backboxColor,
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height,
              ),
              child: IntrinsicHeight(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                      top: height * 0.3,
                      left: width * 0.05,
                      child: Container(
                        width: width * 0.9,
                        padding: EdgeInsets.all(width * 0.1),
                        decoration: BoxDecoration(
                          color: mainboxColor, //fromRGBO(238, 158, 142, 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LOGIN',
                                style: GoogleFonts.teko(
                                  color: Colors.black,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                )),
                            SizedBox(height: height * 0.02),
                            Emailtextfield(
                              bgColor: inputtextColor,
                              hintColor: AppColors.hintColor,
                              hinttext: 'Email',
                              borderWidth: 1,
                              controller: emailController,
                            ),
                            SizedBox(height: height * 0.02),
                            TextField(
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
                                hintText: 'Password',
                                hintStyle: GoogleFonts.inter(
                                    color: AppColors.hintColor),
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
                            SizedBox(height: height * 0.01),
                            Align(
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
                            SizedBox(height: height * 0.02),
                            SizedBox(
                              width: double.infinity,
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
                            SizedBox(height: height * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have a account?"),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      myRoute(SignupPage()),
                                    );
                                  },
                                  child: Text(
                                    "SignUp",
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
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
      //await FirestoreServices().getUserRole();
      if (!mounted) return;
      saveLoginState(true);
      _showSnackBar("login successful!!");
      User? userid = FirebaseAuth.instance.currentUser;
      if (userid == null) {
        _showSnackBar("user not found", isError: true);
      }
      updateFCMToken(userid!.uid);
      Navigator.pushAndRemoveUntil(
          context, myRoute(Splashscreen()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'invalid-credential') {
        _showSnackBar('Invalid email or password. Please try again',
            isError: true);
      } else if (e.code == 'user-not-found') {
        _showSnackBar('No account found. Please sign up first', isError: true);
      } else if (e.code == 'wrong-password') {
        _showSnackBar('Incorrect password. Try again or reset your password',
            isError: true);
      } else if (e.code == 'invalid-email') {
        _showSnackBar('Please enter a valid email address', isError: true);
      } else if (e.code == 'too-many-requests') {
        _showSnackBar('Too many attempts. Please try again later',
            isError: true);
      } else if (e.code == 'network-request-failed') {
        _showSnackBar('Check your internet connection and try again',
            isError: true);
      } else if (e.code == 'user-disabled') {
        _showSnackBar("This account has been disabled. Contact support.");
      } else {
        _showSnackBar('Signup failed: ${e.toString()}');
      }
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
