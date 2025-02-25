import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Mydropdownmenu extends StatefulWidget {
  final Color? buttonColor;
  final String? hinttext;
  final Color? hintColor;
  final Color? bgColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final List<String> list;
  final Color? textColor;
  final double? width;
  final Function(String)? getvalue;

  const Mydropdownmenu({
    super.key,
    this.buttonColor,
    this.hinttext,
    this.hintColor,
    this.bgColor,
    this.borderColor = Colors.green,
    this.borderWidth = 1.0,
    this.borderRadius = 20,
    this.list = const [""],
    this.textColor,
    this.width,
    this.getvalue,
  });

  @override
  State<Mydropdownmenu> createState() => _MydropdownmenuState();
}

class _MydropdownmenuState extends State<Mydropdownmenu> {
  String? listvalue;
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField2<String>(
          iconStyleData: IconStyleData(
            icon: Icon(
              LucideIcons.chevronDown,
              color: widget.buttonColor,
            ),
          ),
          hint: Text(
            widget.hinttext ?? 'Priority',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: widget.hintColor,
            ),
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            filled: true,
            fillColor: widget.bgColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: widget.borderColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: widget.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius + 0.5),
              borderSide: BorderSide(color: widget.borderColor),
            ),
          ),
          isExpanded: true,
          items: widget.list
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: GoogleFonts.inter(
                      color: widget.textColor,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              listvalue = value; // Update listvalue correctly
            });

            if (widget.getvalue != null) {
              widget.getvalue!(value!); // Pass the selected value
            }
          },
          value: listvalue,
          validator: (value) {
            if (value == null) {
              return 'Please select a role';
            }
            return null;
          },
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor),
              borderRadius: BorderRadius.circular(20),
              color: widget.bgColor,
            ),
          ),
          buttonStyleData: ButtonStyleData(
            height: 45,
            width: widget.width,
          ),
        ),
      ),
    );
  }
}
