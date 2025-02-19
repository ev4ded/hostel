import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Test extends StatefulWidget {
  const Test({super.key});
  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  List<String> roleList = ['student', 'warden', 'admin'];
  String? role; // Nullable String

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      iconStyleData: IconStyleData(
        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
      ),
      isExpanded: true,
      items: roleList
          .map((String e) => DropdownMenuItem<String>(
                // Specify <String>
                value: e,
                child: Text(
                  e,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ))
          .toList(),
      onChanged: (String? value) {
        // Ensure value is String?
        setState(() {
          role = value;
        });
      },
      value: role, // Ensure role is a String?
      buttonStyleData: ButtonStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1),
          color: Colors.white,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
      ),
    );
  }
}
