import 'package:flutter/material.dart';
import 'package:my_app/widgets/generic_user_field.dart';
import 'package:my_app/widgets/generic_password_field.dart';
import 'package:my_app/widgets/animated_loading_button.dart';
import 'package:my_app/widgets/generic_snack_bar.dart';
import 'package:my_app/widgets/generic_leave.dart';

import 'package:my_app/other/app_shared_preferences.dart';
import 'package:my_app/other/wrapper.dart';
import 'package:my_app/other/enums.dart' show ButtonState;
import 'package:my_app/other/strings.dart' show ConnectionString,
LogInMistakes, ConnectionProblems;

import 'package:my_app_mongo_api/my_app_api.dart' show UserHubApp, AppException;
import 'package:mongo_dart/mongo_dart.dart' show ConnectionException;


class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();

  String? userError;
  String? passwordError;

  Wrapper<ButtonState> state = Wrapper<ButtonState>(ButtonState.init);

  UserHubApp? userHub;

  Wrapper<bool> isPasswordVisible = Wrapper<bool>(false);
  bool disabled = false;

  final AppSharedPreferences sharedPreferences = AppSharedPreferences();
  Future checkSharedPreferences() async {
    await sharedPreferences.init();
    if (sharedPreferences.getUserName() != null) enter();
  }
  Future saveSharedPreferences(String userName) async {
    while(!sharedPreferences.isLive && mounted) {await Future.delayed(const Duration(seconds: 1));}
    sharedPreferences.setUserName(userName);
  }


  Future openDatabase() async { // Open database and created if has not been created
    if (userHub == null){
      try{
        userHub = await UserHubApp.create(URL: ConnectionString.url);
        await userHub!.open();
      } on AppException{
        userHub = null;
        rethrow;
      } on Exception {
        userHub = null;
        print("Unaccounted Exception");
        rethrow;
      }
    }
    else {
      try{
        await userHub!.open();
      } on AppException {
        rethrow;
      } on Exception {
        print("Unaccounted Exception");
        rethrow;
      }
    }
  }
  Future closeDatabase() async {
    try {
    userHub!.close();
    } on Exception {
      print("UnaccountedException close");
      rethrow;
    }
  }
  Future establishConnection() async {
    try {
      await openDatabase();
      await closeDatabase();
      return;
    } on AppException {
      if (disabled == false) {showActionSnackBar(context, ConnectionProblems.connectionLost, 3);}
      disabled = true;
      setState((){});
    }

    while (disabled && mounted) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        await openDatabase();
        await closeDatabase();
        disabled = false;
      } on AppException {
        disabled = true;
        print("hey");
      }
    }
    setState((){});
    if (mounted) showActionSnackBar(context, ConnectionProblems.connectionFound, 2);
  }

  Future<String?> checkUser(String userName, String setPassword) async {
    String? password = await userHub!.users.findPasswordByName(userName);
    if (password == null) return LogInMistakes.userDoesNotExist;

    if (password != setPassword) return LogInMistakes.wrongPassword;
    return null;
  }
  Future<bool> confirmButton() async {
    passwordError = userError = null;
    String userName = userController.text; String password = passwordController.text;
    String? connectionProblem;
    try {
      await openDatabase();
      connectionProblem = await checkUser(userName, password);
      await closeDatabase();
    } on AppException {
      establishConnection();
      return false;
    } on ConnectionException {
      establishConnection();
      return false;
    }

    if (connectionProblem != null) {
      if (connectionProblem == LogInMistakes.userDoesNotExist) {
        userError = LogInMistakes.userDoesNotExist;
        passwordError = null;
      }
      else {
        passwordError = LogInMistakes.wrongPassword;
        userError = null;
      }
      return false;
    }

    await Future.delayed(const Duration(seconds: 1));

    if (connectionProblem == null) {await saveSharedPreferences(userName); return true;}
    return false;
  }

  void done(bool result) {
    if (result == true) enter();
  }
  void enter()
    => Navigator.pushReplacementNamed(context, "/search_page");

  @override
  void setState(VoidCallback fn){
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    establishConnection();
    checkSharedPreferences();

    super.initState();
    userController.addListener(() => setState(() {}));
  }

  void _update(Function f) {
    if (mounted) setState(() => f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
                const SizedBox(height: 40),
                buildText(),
                const SizedBox(height: 60),
                buildUser(userController : userController,
                    labelText : "Username", hintText: "RomaIsBest",
                    errorMessage: userError),
                const SizedBox(height: 20),
                buildPassword(passwordController: passwordController,
                    update: _update, isPasswordVisible: isPasswordVisible,
                    errorMessage: passwordError),
                buildForgotPassword(),
                const SizedBox(height: 50),
                //buildConfirmButton(),
                buildAnimatedButton(state: state, update: _update,
                    whileLoading: confirmButton, afterLoading: done,
                    wait: 2, child: const Text("Войти"), disabled: disabled),
                const SizedBox(height: 10),
              Align(
                child: buildLeaveButton(
                    context: context, address: "/sign_in",
                    child: const Text("Создать аккаунт")
                ),
                alignment: Alignment.center,
              )
        ],
      )
    )
    );
  }


  Widget buildText() => const Center(
      child: Text("Log in", style: TextStyle(
    fontSize: 40,
    fontFamily: "Times New Roman"
  )));

  Widget buildForgotPassword() => Align(
    child: TextButton(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontSize: 15),
      ),
      onPressed: () {
        final snackBar = SnackBar(
            duration: const Duration(seconds: 6),
            content: const Text("Спроси у Ромы лол"),
            action: SnackBarAction(
              label: "Окей...",
              onPressed: () {},
            )
        );
        
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: const Text('...забыли пароль?'),
    ),
    alignment: Alignment.centerRight,
  );

}
