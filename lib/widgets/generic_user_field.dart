import 'package:flutter/material.dart';
import 'package:my_app/other/wrapper.dart';


Widget buildUser({required TextEditingController userController,
  required String labelText, String? hintText, IconData icon = Icons.person,
  Wrapper<String>? errorMessage}) => TextField(
  controller: userController,
  decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorMessage?.value,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
      suffixIcon: userController.text.isEmpty ?
      Container(width:0) :
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => userController.clear()
      )
  ),
  textInputAction: TextInputAction.done,
);