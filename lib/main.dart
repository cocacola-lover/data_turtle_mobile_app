import 'package:flutter/material.dart';
import 'package:my_app/pages/log_in.dart';
import 'package:my_app/pages/sign_in.dart';
import 'package:my_app/pages/test_page.dart';
import 'package:my_app/pages/test_page2.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        colorSchemeSeed: Colors.red,
        brightness: Brightness.light
    ),
    //initialRoute: '/log_in',
      initialRoute: '/test_page',
    routes: {
      '/log_in':(context) => LogIn(),
      '/sign_in': (context) => SignIn(),
      '/test_page': (context) => TestPage(),
      '/test_page2': (context) => TestPage2()
    }
  ));
}

