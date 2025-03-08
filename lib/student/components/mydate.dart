import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Mydate extends StatefulWidget {
  final String? hinttext;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color? bgColor;
  final Color hintColor;
  final Color textColor;
  final TextEditingController? dateController;
  final bool blockPastDates;
  const Mydate({
    super.key,
    this.hinttext,
    this.borderColor = Colors.green,
    this.borderWidth = 1.0,
    this.borderRadius = 20,
    this.bgColor,
    this.hintColor = Colors.blueGrey,
    this.textColor = Colors.white,
    this.dateController,
    this.blockPastDates = false,
  });

  @override
  State<Mydate> createState() => _MydateState();
}

class _MydateState extends State<Mydate> {
  int year = DateTime.now().year.toInt();
  void _showCalendar() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime(DateTime.now().year + 100),
      initialDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        widget.dateController!.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  void _showBlockedCalendar() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 100),
      initialDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        widget.dateController!.text =
            DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      keyboardType: TextInputType.datetime,
      cursorColor: Colors.lightBlueAccent,
      style: GoogleFonts.inter(color: widget.textColor),
      controller: widget.dateController,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.bgColor,
        hintText: widget.hinttext,
        hintStyle: TextStyle(color: widget.hintColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            width: widget.borderWidth,
            color: widget.borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            width: widget.borderWidth + .5,
            color: widget.borderColor,
          ),
        ),
      ),
      onTap: (widget.blockPastDates) ? _showBlockedCalendar : _showCalendar,
    );
  }
}
