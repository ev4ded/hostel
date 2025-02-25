import 'package:flutter/material.dart';

class Version extends StatefulWidget {
  const Version({super.key});

  @override
  State<Version> createState() => _VersionState();
}

class _VersionState extends State<Version> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("version"),
      ),
    );
  }
}
