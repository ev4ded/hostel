import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/emailtextfield.dart';
import 'package:minipro/student/components/myclipper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:minipro/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _errors = {};
  final _fields = [
    "email",
    "username",
    "hostelId",
    "password",
    "confirmpassword"
  ];
  @override
  void initState() {
    super.initState();
    for (var field in _fields) {
      _controllers[field] = TextEditingController();
      _errors[field] = false;
      _controllers[field]!.addListener(() {
        setState(() {
          _errors[field] = false;
        });
      });
    }
    //hostelIdController.addListener(listen("hostelId"))l
  }

  String? role;
  final _formKey = GlobalKey<FormState>();
  void listen(String text) {
    setState(() {
      _errors[text] = false;
    });
  }

  @override
  void dispose() {
    _controllers["email"]!.dispose();
    _controllers["username"]!.dispose();
    _controllers["hostelId"]!.dispose();
    _controllers["password"]!.dispose();
    _controllers["confirmpassword"]!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backboxColor = Color.fromRGBO(36, 39, 38, 1);
    final Color mainboxColor = Color.fromRGBO(203, 178, 182, 1);
    final Color inputtextColor = Color.fromRGBO(240, 237, 235, 1);
    final Color buttonColor = Color.fromRGBO(230, 128, 78, 1);
    final Color hintColor = Color.fromRGBO(139, 139, 139, 0.5);
    List<String> roleList = ['student', 'warden', 'admin'];

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backboxColor,
      body: LayoutBuilder(builder: (context,constraints){
        return SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height, // Prevent extra space at the bottom
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
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.15, // Adjusted top position
                    left: 20,
                    child: Container(
                      width: width * 0.9,
                      decoration: BoxDecoration(
                        color: mainboxColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Text(
                                'SIGNUP',
                                style: GoogleFonts.teko(
                                  fontSize: 32,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, bottom: 8),
                              child: Mytextfield(
                                hintColor: hintColor,
                                hasError: _errors['hostelId'] ??
                                    false, //to ensure notnull
                                hinttext: 'HOSTEl ID',
                                controller: _controllers["hostelId"],
                                bgColor: inputtextColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Text(
                                    'Role: ',
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField2<String>(
                                          iconStyleData: IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black,
                                            ),
                                          ),
                                          hint: Text(
                                            'SELECT ROLE',
                                            style: GoogleFonts.inter(
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            filled: true,
                                            fillColor: inputtextColor,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                          ),
                                          isExpanded: true,
                                          items: roleList
                                              .map(
                                                (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          )
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              role = value.toString();
                                            });
                                          },
                                          value: role,
                                          /*validator: (value) {
                                          if (value == null) {
                                            return 'Please select a role';
                                          }
                                          return null;
                                        },*/
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              color: inputtextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Mytextfield(
                                  hintColor: hintColor,
                                  hasError: _errors['username'] ?? false,
                                  hinttext: 'USERNAME',
                                  controller: _controllers["username"],
                                  bgColor: inputtextColor),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Emailtextfield(
                                  hintColor: hintColor,
                                  hasError: _errors['email'] ?? false,
                                  hinttext: 'EMAIL-ID',
                                  controller: _controllers["email"],
                                  bgColor: inputtextColor),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Mytextfield(
                                hintColor: hintColor,
                                hasError: _errors['password'] ?? false,
                                hinttext: 'PASSWORD',
                                controller: _controllers["password"],
                                bgColor: inputtextColor,
                                isHidden: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Mytextfield(
                                  hintColor: hintColor,
                                  hasError: _errors['confirmpassword'] ?? false,
                                  hinttext: 'CONFIRM PASSWORD',
                                  controller: _controllers["confirmpassword"],
                                  isHidden: true,
                                  bgColor: inputtextColor),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: width * 0.9,
                                  height: height * 0.06,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _validateInput();
                                      createUser();
                                      //clearTextField();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                      WidgetStatePropertyAll(buttonColor),
                                    ),
                                    child: Text(
                                      "SIGNUP",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
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
                                  Text("Already have an account?"),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                          context, myRoute(LoginPage()));
                                    },
                                    child: Text(
                                      "LogIn",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      })
    );
  }

  void clearTextField() {
    _controllers["email"]!.clear();
    _controllers["username"]!.clear();
    _controllers["hostelId"]!.clear();
    _controllers["password"]!.clear();
    _controllers["confirmpassword"]!.clear();
  }

  void deleteTextField() {}
  void createUser() async {
    String username = _controllers["username"]!.text.trim();
    String email = _controllers["email"]!.text.trim();
    String hostelId = _controllers["hostelId"]!.text.trim();
    String password = _controllers["password"]!.text.trim();
    String confirmPassword = _controllers["confirmpassword"]!.text.trim();
    if (email.isEmpty ||
        password.isEmpty ||
        hostelId.isEmpty ||
        username.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }
    if (role == null) {
      _showSnackBar('Please select a role', isError: true);
      return;
    }
    try {
      if (password != confirmPassword) {
        _showSnackBar('Passwords do not match', isError: true);
        return;
      }
      /*if(user.user!.emailVerified == false){
        await user.user!.sendEmailVerification();
      }*/
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      //await FirestoreServices().getUserData();
      await _auth.currentUser?.reload();
      //User? user = _auth.currentUser;
      String uid = userCredential.user!.uid;
      await _firestore.collection("users").doc(uid).set(
        {
          'username': username,
          'email': email,
          'role': role,
          'hostelId': hostelId,
          'roomId': '',
          'isApproved': true,
        },
      );
      await FirestoreServices().getUserData();
      if (!mounted) return;
      _showSnackBar("Signup successful!!");
      saveLoginState(true);
      Navigator.pushReplacement(context, myRoute(Splashscreen()));
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
    setState(
      () {
        for (var field in _fields) {
          if (_controllers[field]!.text.isEmpty) {
            //print("field is empty");
            _errors[field] = true; //set error true
          }
        }
      },
    );
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}
