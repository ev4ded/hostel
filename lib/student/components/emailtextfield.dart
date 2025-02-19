import 'package:flutter/material.dart';

class Emailtextfield extends StatelessWidget {
  final String? labelText;
  final String? hinttext;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool hasError;
  final Color? bgColor;
  final TextEditingController? controller;
  const Emailtextfield({
    super.key,
    this.hasError = false,
    this.labelText,
    this.hinttext,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.borderRadius = 20,
    this.controller,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.black),
      keyboardType: TextInputType.emailAddress,
      controller: controller,
      decoration: InputDecoration(
        errorText: hasError ? "Invalid" : null,
        errorStyle: TextStyle(color: Colors.red),
        filled: true,
        fillColor: bgColor,
        labelText: labelText,
        hintText: hinttext,
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
