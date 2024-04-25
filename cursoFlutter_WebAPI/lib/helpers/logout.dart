import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

logout(BuildContext context) {
  SharedPreferences.getInstance().then((value) {
    value.clear();
    Navigator.pushReplacementNamed(context, "login");
  });
}
