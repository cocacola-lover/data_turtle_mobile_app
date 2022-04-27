import 'package:flutter/material.dart';
import 'package:my_app/other/wrapper.dart';

const _labelExample = 'password';

Widget buildPassword({required TextEditingController passwordController,
  required Function(Function) update, required Wrapper<bool> isPasswordVisible,
  String labelText = _labelExample, IconData passwordIcon = Icons.security, String? errorMessage})
  => TextField(
    controller: passwordController,
    decoration: InputDecoration(
      labelText: labelText,
      errorText: errorMessage,
      prefixIcon: Icon(passwordIcon),
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: !isPasswordVisible.value ?
        const Icon(Icons.visibility_off):
        const Icon(Icons.visibility),
        onPressed: () {
          isPasswordVisible.value = !isPasswordVisible.value;
          update(() => isPasswordVisible.value = !isPasswordVisible.value);
        },
      )
  ),
    textInputAction: TextInputAction.done,
    obscureText: !isPasswordVisible.value,
);
