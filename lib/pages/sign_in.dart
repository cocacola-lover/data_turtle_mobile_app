import 'package:flutter/material.dart';
import 'package:my_app/widgets/generic_user_field.dart';
import 'package:my_app/widgets/generic_password_field.dart';
import 'package:my_app/widgets/animated_loading_button.dart';

import 'package:my_app/checks/field_checker.dart';
import 'package:my_app/checks/password_checker.dart';

import 'package:my_app/other/wrapper.dart';
import 'package:my_app/other/button_enum.dart';

import 'package:my_app_mongo_api/my_app_api.dart' show UserHubApp, AppException;

//const url = "mongodb+srv://Admin:2xxRHKviEsp6AKq@cluster0.gdgrc.mongodb.net/app_files?retryWrites=true&w=majority";
const url = "mongodb+srv://Admin:2xxRHKviEsp6AKq@cluster1.gdgrc.mongodb.net/app_files?retryWrites=true&w=majority";
const _passwordsAreNotSame = "Пароли должны совпадать";
const _unthinkableMessage = "Something went really wrong here";
const _toManyUsers = "К сожалению, лимит пользователей был достигнут";
const _somethingWentWrong = "Что-то пошло не так";

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  Wrapper<ButtonState> state = Wrapper<ButtonState>(ButtonState.init);
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  String? userError;
  String? passwordError;
  String? passwordConfirmError;

  final passwordChecker = PasswordChecker();
  Wrapper<bool> isPasswordVisible = Wrapper<bool>(false);

  late final UserHubApp userHub;
  Future<String?>? dataBaseErr;

  Future<String?> openDatabase() async {
    userHub = await UserHubApp.create(URL: url);
    try {
      await userHub.open();
    } on AppException catch (e) {
      return e.exceptionMessage;
    }
    return null;
  }


  @override
  void setState(VoidCallback fn){
    if (mounted) super.setState(fn);
  }

  Future<String?> createUser() async {
    if (await userHub.users.count() > 10) return _toManyUsers;

    if (await userHub.users.addUser(userController.text,
        passwordController.text) == false) return _somethingWentWrong;

    return null;
  }

  Future<bool> confirmButton() async{
      userError = checkField(userController.text);
      passwordError = null;//passwordChecker.check(passwordController.text);
      passwordConfirmError = (passwordController.text != passwordConfirmController.text) ? _passwordsAreNotSame : null;
      if (userError != null || passwordError != null || passwordConfirmError != null) return false;
      await Future.delayed(const Duration(seconds: 2));

      if (dataBaseErr == null) throw AppException(_unthinkableMessage);
      passwordConfirmError = await dataBaseErr;
      passwordConfirmError ??= await createUser();

      if (passwordConfirmError == null) return true;
      return false;
  }

  void niceGoBack() {
    Navigator.pushReplacementNamed(context, '/log_in');
  }


  @override
  void initState() {
    super.initState();
    try {
      dataBaseErr = openDatabase();
    } on Mon catch (e):


    userController.addListener(() => setState(() {}));
  }

  void _update(Function f) => setState(() => f);

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
                buildUser(userController : userController, labelText : "Username",
                    hintText: "RomaIsBest", errorMessage: userError),
                const SizedBox(height: 20),
                buildPassword(
                    passwordController: passwordController, update: _update,
                    isPasswordVisible: isPasswordVisible, errorMessage: passwordError
                ),
                const SizedBox(height: 20),
                buildPassword(
                    passwordController: passwordConfirmController,
                    update: _update, isPasswordVisible: isPasswordVisible,
                    labelText: "Confirm password", passwordIcon: Icons.lock_outline,
                    errorMessage: passwordConfirmError
                ),
                const SizedBox(height: 40),
                Container(
                    child: buildAnimatedButton(
                        color: Colors.red, width: 150, height: 40, state: state,
                        update: _update, whileLoading: confirmButton, wait: 3,
                        afterLoading: niceGoBack

                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                ),
                //const SizedBox(height: 10),
                buildHaveAccountButton()
              ],
            )
        )
    );
  }


  Widget buildText() => const Center(
      child: Text("Sign in", style: TextStyle(
          fontSize: 40,
          fontFamily: "Times New Roman"
      )));


  Widget buildConfirmButton() => Align(
      child: SizedBox(
          child: ElevatedButton(onPressed: () {}, child: const Text("Регистрация")),
          width: 150,
          height: 40
      ),
      alignment: Alignment.center
  );

  Widget buildHaveAccountButton() => Align(
      child: SizedBox(
          child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/log_in');
                //Navigator.pushNamed(context, '/log_in');
              },
              child: const Text("Уже есть аккаунт?")
          ),
          width: 150,
          height: 40
      ),
      alignment: Alignment.center
  );
}
