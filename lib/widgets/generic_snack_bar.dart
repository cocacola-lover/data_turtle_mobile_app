import 'package:flutter/material.dart';

const _dismiss = "Dismiss";

void showActionSnackBar(BuildContext context, String text, int seconds){
  final snackBar = SnackBar(
    content: Text(text),
    duration: Duration(seconds: seconds),
    action: SnackBarAction(
      label: _dismiss,
      onPressed: () {},
    ),
  );
  
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}