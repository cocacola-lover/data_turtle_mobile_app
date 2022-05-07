import 'package:flutter/material.dart';
import 'package:my_app/widgets/generic_user_field.dart';
import 'package:my_app/widgets/generic_password_field.dart';
import 'package:my_app/widgets/animated_loading_button.dart';
import 'package:my_app/widgets/generic_snack_bar.dart';

import 'package:my_app/other/wrapper.dart';
import 'package:my_app/enums/button_enum.dart';

import 'package:my_app_mongo_api/my_app_api.dart' show UserHubApp, AppException;

const url = "mongodb+srv://Admin:2xxRHKviEsp6AKq@cluster0.gdgrc.mongodb.net/app_files?retryWrites=true&w=majority";
const _unthinkableMessage = "Should not happen";
const _userDoesNotExist = "User doesn't exist";
const _wrongPassword = "Wrong password";

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

  late final UserHubApp userHub;
  Future<String?>? dataBaseErr;

  Wrapper<bool> isPasswordVisible = Wrapper<bool>(false);

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

  Future<String?> checkUser() async {
    String? password = await userHub.users.findPasswordByName(userController.text);
    if (password == null) return _userDoesNotExist;

    if (password != passwordController.text) return _wrongPassword;
    return null;
  }

  Future<bool> confirmButton() async {
    String? connectionProblem;
    if (dataBaseErr == null) throw AppException(_unthinkableMessage);
    connectionProblem = await dataBaseErr;

    if (connectionProblem != null) {
      showActionSnackBar(context, connectionProblem, 3);
      return false;
    }

    // Checking user
    connectionProblem ??= await checkUser();

    if (connectionProblem != null) {
      if (connectionProblem == _userDoesNotExist) {
        userError = _userDoesNotExist;
        passwordError = null;
      }
      else {
        passwordError = _wrongPassword;
        userError = null;
      }
      return false;
    }

    await Future.delayed(const Duration(seconds: 1));

    passwordError = userError = null;

    return connectionProblem == null;
  }

  void done(bool result) {
    showActionSnackBar(context, result.toString(), 3);
  }

  @override
  void initState() {
    dataBaseErr = openDatabase();

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
                    wait: 2, child: const Text("Войти")),
                const SizedBox(height: 10),
                buildSignInButton()
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

  Widget buildConfirmButton() => Align(
      child: SizedBox(
          child: ElevatedButton(onPressed: () {}, child: const Text("Войти")),
          width: 150,
          height: 40
      ),
      alignment: Alignment.center
  );

  Widget buildSignInButton() => Align(
      child: SizedBox(
          child: TextButton(
              onPressed: () {
                  Navigator.pushReplacementNamed(context, '/sign_in');
                  //Navigator.pushNamed(context, '/sign_in');
              },
              child: const Text("Создать Аккаунт")
          ),
          width: 150,
          height: 40
      ),
      alignment: Alignment.center
  );
}
