import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Authprovider with ChangeNotifier {
  User? _user = FirebaseAuth.instance.currentUser;
  User? get user => _user;

  void refreshUser() {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }
}
