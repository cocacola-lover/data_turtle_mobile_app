import 'package:flutter/material.dart';

Widget buildLeaveButton({required BuildContext context, required String address, required Widget child,
  bool replace = true, double width = 200, double height = 40}) => SizedBox(
    child: TextButton(
      onPressed: replace ? () => Navigator.pushReplacementNamed(context, address)
          : () => Navigator.pushNamed(context, address),
      child: child
    ),
    width: width,
    height: height
);