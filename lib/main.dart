import 'package:flutter/material.dart';
import 'package:my_app/pages/log_in.dart';
import 'package:my_app/pages/sign_in.dart';
import 'package:my_app/pages/action_page.dart';
import 'package:my_app/pages/search_page.dart';
import 'package:my_app/pages/setting_page.dart';
import 'package:my_app/pages/loading_page.dart';
import 'package:my_app/pages/change_page.dart';
import 'package:my_app/other/strings.dart' show Routes;

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light
    ),
      initialRoute: Routes.loadingPage,
    routes: {
      Routes.logIn:(context) => const LogIn(),
      Routes.signIn: (context) => const SignIn(),
      Routes.actionPage: (context) => const ActionPage(),
      Routes.searchPage : (context) => const SearchPage(),
      Routes.settingPage: (context) => const SettingsPage(),
      Routes.loadingPage: (context) => const LoadingPage(),
      Routes.changePage: (context) => const ChangePage()
    }
  ));
}

