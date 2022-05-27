import 'package:flutter/material.dart';

class Tag extends StatelessWidget {

  final String name;
  final ValueChanged<Tag>? onPressed;
  final ValueChanged<Tag>? onDeleted;

  final MaterialColor color;

  const Tag({
    Key? key,
    required this.name,
    this.color = Colors.cyan,
    this.onDeleted,
    this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black),
        color: color,
      ),
        padding: const EdgeInsets.only(left: 10),
      child: onDeleted != null ? Row(
        children: [
          buildText(),
          IconButton(onPressed: () => onDeleted?.call(this), icon: const Icon(Icons.clear))
        ],
      ) : buildText()
    );
  }

  Widget buildText() => onPressed != null ? TextButton(
      child: Text(name),
      onPressed: () => onPressed?.call(this)
  ) : Text(name);
}
