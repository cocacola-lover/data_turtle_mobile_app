import 'package:flutter/material.dart';
import 'package:my_app/widgets/generic_user_field.dart';
import 'package:my_app/widgets/generic_password_field.dart';
import 'package:my_app/widgets/animated_loading_button.dart';
import 'package:my_app/widgets/generic_snack_bar.dart';
import 'package:my_app/widgets/generic_leave.dart';

import 'package:my_app/checks/field_checker.dart';
import 'package:my_app/checks/password_checker.dart';

import 'package:my_app/other/wrapper.dart';
import 'package:my_app/other/enums.dart' show ButtonState;
import 'package:my_app/other/strings.dart' show ConnectionString, OtherMistakes, SignInMistakes;

import 'package:my_app_mongo_api/my_app_api.dart' show UserHubApp, AppException;

const url = ConnectionString.url;

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
    try {
      userHub = await UserHubApp.create(URL: url);
      await userHub.open();
    } on AppException catch (e) {
      return e.exceptionMessage;
    } catch (e){
      rethrow;
    }
    return null;
  }


  @override
  void setState(VoidCallback fn){
    if (mounted) super.setState(fn);
  }

  Future<String?> createUser() async {
    if (await userHub.users.count() > 10) return SignInMistakes.tooManyUsers;

    if (await userHub.users.addUser(userController.text,
        passwordController.text) == false) return OtherMistakes.somethingWentWrong;

    return null;
  }

  Future<bool> confirmButton() async{
        // Checking connection
        String? connectionProblem;
        if (dataBaseErr == null) throw AppException(OtherMistakes.unthinkableMessage);
        connectionProblem = await dataBaseErr;

        if (connectionProblem != null) {
          showActionSnackBar(context, connectionProblem, 3);
          return false;
        }
        // Checking fields
        userError = checkField(userController.text);
        passwordError = passwordChecker.check(passwordController.text);
        passwordConfirmError = (passwordController.text != passwordConfirmController.text) ? SignInMistakes.passwordsAreNotSame : null;
        if (userError != null || passwordError != null || passwordConfirmError != null) return false;
        await Future.delayed(const Duration(seconds: 2));

        // Adding new user
        connectionProblem ??= await createUser();

        if (connectionProblem != null) {
          showActionSnackBar(context, connectionProblem, 3);
          return false;
        }

        return connectionProblem == null;
  }

  void niceGoBack(bool result) {
     if (result == true) Navigator.pushReplacementNamed(context, '/log_in');
  }


  @override
  void initState() {
    super.initState();
    dataBaseErr = openDatabase();


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
                        afterLoading: niceGoBack, child: const Text("Регистрация")

                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                ),
                //const SizedBox(height: 10),
                Align(
                  child: buildLeaveButton(
                      context: context, address: "/log_in",
                      child: const Text("Уже есть аккаунт?")
                  ),
                  alignment: Alignment.center,
                )
                //buildHaveAccountButton()
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

}
