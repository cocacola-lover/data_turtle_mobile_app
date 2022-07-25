import 'package:flutter/material.dart';
import 'package:my_app/pages/log_in.dart';
import 'package:my_app/pages/sign_in.dart';
import 'package:my_app/pages/test_page.dart';
import 'package:my_app/pages/test_page2.dart';
import 'package:my_app/pages/action_page.dart';
import 'package:my_app/pages/search_page.dart';
import 'package:my_app/pages/setting_page.dart';
import 'package:my_app/pages/loading_page.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        colorSchemeSeed: Colors.red,
        brightness: Brightness.light
    ),
      initialRoute: '/action_page',
    routes: {
      '/log_in':(context) => const LogIn(),
      '/sign_in': (context) => const SignIn(),
      '/test_page': (context) => const TestPage(),
      '/test_page2': (context) => const TestPage2(),
      '/action_page': (context) => const ActionPage(isNew: true,),
      '/search_page' : (context) => const SearchPage(),
      '/settings_page': (context) => const SettingsPage(),
      '/loading_page': (context) => const LoadingPage()
    }
  ));
}

