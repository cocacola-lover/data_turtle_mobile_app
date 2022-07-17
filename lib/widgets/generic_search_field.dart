import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController fieldController;
  final bool keyboardIsShown;
  final IconButton? preButton;
  final IconButton? secondButton;
  final IconButton searchButton;

  final ValueChanged<bool>? onFocusChanged;
  final FocusNode? focusNode;
  final bool disabled;


  const SearchField(
      {Key? key, required this.fieldController, this.keyboardIsShown = true,
      required this.searchButton, this.secondButton, this.preButton,
        this.onFocusChanged, this.disabled = false, this.focusNode}) : super(key: key);

  @override
  Widget build(BuildContext context){
    List<Widget> children = [
      onFocusChanged == null ?
      Flexible(
        child: TextField(
          focusNode: focusNode,
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
              focusNode: focusNode,
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

class SearchFieldV2 extends StatelessWidget {
  const SearchFieldV2({Key? key, this.focusNode, this.fieldController,
    this.preButton, this.searchButton, this.secondButton, this.disabled = false}) : super(key: key);

  final bool disabled;
  final FocusNode? focusNode;
  final TextEditingController? fieldController;
  final IconButton? preButton;
  final IconButton? secondButton;
  final IconButton? searchButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        preButton != null ? preButton as IconButton : const SizedBox(),
        Flexible(
          child: TextField(
            readOnly: disabled,
            showCursor: !disabled,
            focusNode: focusNode,
            controller: fieldController,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(6)
            ),
          ),
        ),
        secondButton != null ? secondButton as IconButton : const SizedBox(),
        searchButton != null ? searchButton as IconButton : const SizedBox(),
      ],
    );
  }
}

