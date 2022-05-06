import 'package:flutter/material.dart';

import 'package:my_app/other/wrapper.dart';
import 'package:my_app/enums/button_enum.dart';

Widget buildAnimatedButton({ required Wrapper<ButtonState> state, required Function(Function) update,
  required Future<bool> Function() whileLoading, Function(bool result)? afterLoading, int wait = 0,
  MaterialColor color = Colors.indigo, double? width, double? height}) =>
    Container(
      width: width,
      height: height,
      child: (state.value == ButtonState.init) ?
      _buildButton(
        update:update, state: state, color: color, width: width, height: height,
        whileLoading: whileLoading, afterLoading: afterLoading, wait:wait
      ):
      _buildSmallButton(color:color, width: width, height: height, state: state),
  );

Widget _buildButton({required Function(Function) update, required Wrapper<ButtonState> state,
  required Future<bool> Function() whileLoading, Function(bool result)? afterLoading, int wait = 0,
  MaterialColor color = Colors.indigo, double? width, double? height}) =>
    SizedBox(
      child: ElevatedButton(
        onPressed: () async {
          state.value = ButtonState.loading;
          update(() {});
          state.value = (await whileLoading()) ? ButtonState.done : ButtonState.failed;
          update(() {});
          await Future.delayed(Duration(seconds: wait));
          if (afterLoading != null) afterLoading(state.value == ButtonState.done);
          state.value = ButtonState.init;
          update(() {});
        },
        child: const Text("Регистрация")
      ),
      width: width,
      height: height
);

Widget _buildSmallButton({required MaterialColor color, required Wrapper<ButtonState> state, double? width, double? height}) {
  Widget child;
  MaterialColor colorB;
  if (state.value == ButtonState.loading){
    colorB = color;
    child = SizedBox(
      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
      height: height == null ? 10 : height/2,
      width: height == null ? 10 : height/2,
    );
  } else if (state.value == ButtonState.done) {
    colorB = Colors.green;
    child = const Icon(Icons.done, color: Colors.white);
  } else {
    colorB = Colors.red;
    child = const Icon(Icons.clear, color: Colors.white);
  }

  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(shape:BoxShape.circle, color: colorB),
    child: Center(
      child: child
    )
  );
}