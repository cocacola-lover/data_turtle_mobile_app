import 'package:flutter/material.dart';
import 'package:my_app/widgets/generic_user_field.dart';
import 'package:my_app/widgets/generic_password_field.dart';
import 'package:my_app/widgets/animated_loading_button.dart';

import 'package:my_app/other/wrapper.dart';
import 'package:my_app/other/button_enum.dart';

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

  Wrapper<bool> isPasswordVisible = Wrapper<bool>(false);

  @override
  void initState() {
    super.initState();

    userController.addListener(() => setState(() {}));
  }

  void _update(Function f) => setState(() => f);

  @override
  Widget build(BuildContext context) {
    Wrapper<bool> isStretched = Wrapper<bool>(state.value == ButtonState.init);
    Wrapper<bool> isDone = Wrapper<bool>(state.value == ButtonState.done);
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
                buildPassword(
                    passwordController: passwordController,
                    update: _update, isPasswordVisible: isPasswordVisible
                ),
                const SizedBox(height: 20),
                buildPassword(
                    passwordController: passwordConfirmController,
                    update: _update, isPasswordVisible: isPasswordVisible,
                    labelText: "Confirm password", passwordIcon: Icons.lock_outline
                ),
                //buildForgotPassword(),
                const SizedBox(height: 50),
                buildConfirmButton(),
                const SizedBox(height: 10),
                //buildHaveAccountButton()
                Container(
                    child: buildAnimatedButton(
                        color: Colors.red, width: 150, height: 40,
                        isStretched: isStretched, isDone: isDone, state: state, update: _update
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(33),
                )
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
