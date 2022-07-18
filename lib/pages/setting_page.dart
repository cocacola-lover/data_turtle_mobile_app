import 'package:flutter/material.dart';
import 'package:my_app/other/app_shared_preferences.dart' show AppSharedPreferences;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppSharedPreferences sharedPreferences = AppSharedPreferences();
  Future initSharedPreferences() async => await sharedPreferences.init();
  Future waitForInit() async {
    if (!sharedPreferences.isLive && mounted) Future.delayed(const Duration(milliseconds: 10));
  }
  Future deleteUserInfo() async {
    await waitForInit();
    await sharedPreferences.deleteUserName();
    await sharedPreferences.deleteUserObjectId();
  }
  Future goToLogin() async{
    await deleteUserInfo();
    Navigator.pushReplacementNamed(context, "/log_in");
  }
  void goToSearch() {
    Navigator.pushReplacementNamed(context, "/search_page");
  }

  //override
  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
         goToSearch();
         return false;
        },
        child: Scaffold(
          body: Column(
            children: [
              Center(
                child:ElevatedButton(onPressed: goToLogin, child: const Text("Выйти"))
              )
            ],
          )
        ),
      ),
    );
  }
}
