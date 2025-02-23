import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Mytextfield extends StatelessWidget {
  final String? labelText;
  final String? hinttext;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool isHidden;
  final bool hasError;
  final Color? bgColor;
  final Color hintColor;
  final Color textColor;
  final TextEditingController? controller;
  const Mytextfield({
    super.key,
    this.labelText,
    this.textColor = Colors.black,
    this.hintColor = Colors.blueGrey,
    this.hasError = false,
    this.hinttext,
    this.bgColor,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.borderRadius = 20,
    this.isHidden = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.lightBlueAccent,
      style: GoogleFonts.inter(color: textColor),
      controller: controller,
      obscureText: isHidden,
      decoration: InputDecoration(
        errorText: hasError ? "Invalid" : null,
        errorStyle: TextStyle(color: Colors.red),
        filled: true,
        fillColor: bgColor,
        labelText: labelText,
        hintText: hinttext,
        hintStyle: TextStyle(color: hintColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            width: borderWidth,
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            width: borderWidth + .5,
            color: borderColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            width: borderWidth + .5,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
