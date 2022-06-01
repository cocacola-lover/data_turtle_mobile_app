import 'package:flutter/material.dart';

class TestPage2 extends StatefulWidget {
  const TestPage2({Key? key}) : super(key: key);

  @override
  State<TestPage2> createState() => _TestPage2State();
}

class _TestPage2State extends State<TestPage2> {
  bool keyboardIsShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              Expanded(child: TextField(
                readOnly: !keyboardIsShown,
                decoration: InputDecoration(
                  suffixIcon: IconButton(onPressed: () {setState(() {
                    keyboardIsShown = !keyboardIsShown;
                  });}, icon: Icon(Icons.keyboard))
                ),
              )),
            ],
          )
        ],
      )
    );
  }
}
