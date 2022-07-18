import 'package:flutter/material.dart';
import 'package:my_app/other/app_shared_preferences.dart' show AppSharedPreferences;

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  Future checkSharedPreference() async {
    final sf = AppSharedPreferences();
    await sf.init();
    if (sf.getUserName() != null) {
      Navigator.pushReplacementNamed(context, "/search_page");
      return;
    }
    Navigator.pushReplacementNamed(context, "/log_in");
  }

  @override
  void initState(){
    super.initState();
    checkSharedPreference();
  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
