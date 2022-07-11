import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController fieldController;
  final bool keyboardIsShown;
  final IconButton? preButton;
  final IconButton? secondButton;
  final IconButton searchButton;

  final ValueChanged<bool>? onFocusChanged;
  final bool disabled;


  const SearchField(
      {Key? key, required this.fieldController, this.keyboardIsShown = true,
      required this.searchButton, this.secondButton, this.preButton,
        this.onFocusChanged, this.disabled = false}) : super(key: key);

  @override
  Widget build(BuildContext context){
    List<Widget> children = [
      onFocusChanged == null ?
      Flexible(
        child: TextField(
          readOnly: !keyboardIsShown || disabled,
          showCursor: keyboardIsShown && !disabled,
          controller: fieldController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(6)
          ),
        ),
      ) : Flexible(
          child: Focus(
            onFocusChange: onFocusChanged,
            child: TextField(
              readOnly: !keyboardIsShown || disabled,
              showCursor: keyboardIsShown && !disabled,
              controller: fieldController,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(6)
              ),
            ),
        ),
      ),
      searchButton
    ];
    if (secondButton != null) children.insert(1, secondButton as IconButton);
    if (preButton != null) children.insert(0, preButton as IconButton);

    return SizedBox(
        child: Row(children: children)
    );
  }
}
