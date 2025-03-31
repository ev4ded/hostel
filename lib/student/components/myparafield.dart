import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Myparafield extends StatelessWidget {
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final Color textColor;
  final Color bgColor;
  final Color hintColor;
  final TextEditingController? controller;
  final String? hintText;
  final int noOfLine;
  const Myparafield({
    super.key,
    this.controller,
    this.hintText,
    this.noOfLine = 5,
    this.borderWidth = 1.0,
    this.borderRadius = 15,
    this.borderColor = Colors.white,
    this.textColor = Colors.white,
    this.bgColor = Colors.grey,
    this.hintColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: noOfLine,
      keyboardType: TextInputType.multiline,
      textAlignVertical: TextAlignVertical.top,
      style: GoogleFonts.inter(color: textColor),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: bgColor,
        hintText: hintText ?? "describe your issue here",
        hintStyle: TextStyle(
          color: hintColor,
        ),
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
      ),
    );
  }
}
