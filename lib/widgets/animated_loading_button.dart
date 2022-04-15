import 'package:flutter/material.dart';

import 'package:my_app/other/wrapper.dart';
import 'package:my_app/other/button_enum.dart';

Widget buildAnimatedButton({required Wrapper<bool> isStretched, required Wrapper<bool> isDone,
  required Wrapper<ButtonState> state, required Function(Function) update,
  MaterialColor color = Colors.indigo, double? width, double? height}) =>
    Container(
      width: width,
      height: height,
      child: isStretched.value ?
      _buildButton(update:update, state: state, color: color, width: width, height: height, isStretched: isStretched):
      _buildSmallButton(color:color, width: width, height: height, isDone: isDone),
  );

Widget _buildButton({required Function(Function) update, required Wrapper<ButtonState> state, required Wrapper<bool> isStretched,
  MaterialColor color = Colors.indigo, double? width, double? height}) =>
    SizedBox(
      child: ElevatedButton(
        onPressed: () async {
          state.value = ButtonState.loading;
          update(() {});
          await Future.delayed(const Duration(seconds:3));
          state.value = ButtonState.done;
          update(() {});
          await Future.delayed(const Duration(seconds:3));
          state.value = ButtonState.init;
          update(() {});
        },
        child: const Text("Регистрация")
      ),
      width: width,
      height: height
);

Widget _buildSmallButton({required MaterialColor color, required Wrapper<bool> isDone, double? width, double? height}) => Container(
    //width: width,
    //height: height,
    alignment: Alignment.center,
    padding: EdgeInsets.all(5),
    decoration: BoxDecoration(shape:BoxShape.circle, color: isDone.value ? Colors.green : color),
    child: Center(
      child: !isDone.value ? SizedBox(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          height: height == null ? 10 : height/2,
          width: height == null ? 10 : height/2,
      ): Icon(Icons.done, color: Colors.white)
    )
);