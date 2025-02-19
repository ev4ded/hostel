import 'package:flutter/material.dart';

class Inputscreen extends StatefulWidget {
  const Inputscreen({super.key});

  @override
  InputscreenstateState createState() => InputscreenstateState();
}

class InputscreenstateState extends State<Inputscreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController wardenIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
