import 'package:flutter/material.dart';

Widget buildUser({required TextEditingController userController,
  required String labelText, String? hintText, IconData icon = Icons.person,
  String? errorMessage}) => TextField(
    controller: userController,
    decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorMessage,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        suffixIcon: userController.text.isEmpty ?
        Container(width: 0) :
        IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => userController.clear()
        )
    ),
    textInputAction: TextInputAction.done,
  );