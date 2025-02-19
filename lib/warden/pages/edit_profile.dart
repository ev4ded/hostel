import 'package:flutter/material.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E d i t  P r o f i l e'),
      ),
      body: const Center(
        child: Text('Welcome to the Edit Profile Page!'),
      ),
    );
  }
}