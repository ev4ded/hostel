import 'package:flutter/material.dart';

class Mytextfield extends StatelessWidget {
  final String? labelText;
  final String? hinttext;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool isHidden;
  final bool hasError;
  final Color? bgColor;
  final TextEditingController? controller;
  const Mytextfield({
    super.key,
    this.labelText,
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
      style: TextStyle(color: Colors.black),
      controller: controller,
      obscureText: isHidden,
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
