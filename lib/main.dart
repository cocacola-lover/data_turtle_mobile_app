import 'package:flutter/material.dart';
import 'package:my_app/pages/log_in.dart';
import 'package:my_app/pages/sign_in.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        colorSchemeSeed: Colors.red,
        brightness: Brightness.light
    ),
    initialRoute: '/log_in',
    routes: {
      '/log_in':(context) => LogIn(),
      '/sign_in': (context) => SignIn()
    }
  ));
}

