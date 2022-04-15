import 'package:flutter/material.dart';
import 'package:my_app/widgets/generic_user_field.dart';
import 'package:my_app/widgets/generic_password_field.dart';
import 'package:my_app/other/wrapper.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();

  Wrapper<bool> isPasswordVisible = Wrapper<bool>(false);

  @override
  void initState() {
    super.initState();
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
                buildUser(userController : userController,
                    labelText : "Username", hintText: "RomaIsBest"),
                const SizedBox(height: 20),
                buildPassword(passwordController: passwordController,
                    update: _update, isPasswordVisible: isPasswordVisible),
                buildForgotPassword(),
                const SizedBox(height: 50),
                buildConfirmButton(),
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
