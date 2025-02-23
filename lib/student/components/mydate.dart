import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Mydate extends StatefulWidget {
  final String? hinttext;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color? bgColor;
  final Color hintColor;
  final Color textColor;
  final TextEditingController? datecontroller;
  const Mydate({
    super.key,
    this.hinttext,
    this.borderColor = Colors.green,
    this.borderWidth = 1.0,
    this.borderRadius = 20,
    this.bgColor,
    this.hintColor = Colors.blueGrey,
    this.textColor = Colors.white,
    this.datecontroller,
  });

  @override
  State<Mydate> createState() => _MydateState();
}

class _MydateState extends State<Mydate> {
  DateTime _selectedDay = DateTime.now();
  int year = DateTime.now().year.toInt();
  void _showCalendar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.height) * 0.48,
          child: TableCalendar(
            headerStyle:
                HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarFormat: CalendarFormat.month,
            //onFormatChanged: (format) => CalenderFormat,
            calendarStyle: CalendarStyle(defaultTextStyle: GoogleFonts.inter()),
            firstDay: DateTime.utc(year - 4, 1, 1),
            lastDay: DateTime.utc(year + 4, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                widget.datecontroller!.text =
                    DateFormat('dd-MM-yyyy').format(selectedDay);
              });
              Navigator.pop(context); // Close dialog after selection
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      keyboardType: TextInputType.datetime,
      cursorColor: Colors.lightBlueAccent,
      style: GoogleFonts.inter(color: widget.textColor),
      controller: widget.datecontroller,
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
      onTap: _showCalendar,
    );
  }
}
