import 'package:flutter/material.dart';
import 'package:my_app/widgets/tag.dart';

class AutoCompleteTagField extends StatefulWidget {

  const AutoCompleteTagField({
    Key? key,
    required this.tagBar,
    this.onFieldChanged,
    this.onTagBarChanged,
    this.onTagDelete
  }) : super(key : key);

  final List<Widget> tagBar;
  final ValueChanged<Widget>? onTagBarChanged;
  final ValueChanged<String>? onFieldChanged;
  final ValueChanged<Widget>? onTagDelete;



  @override
  State<AutoCompleteTagField> createState() => _AutoCompleteTagFieldState();
}

class _AutoCompleteTagFieldState extends State<AutoCompleteTagField> {

  final fieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: widget.tagBar,
          ),
          Row(
            children: [
                buildSearchField()
            ],
          )
        ],
      ),
    );
  }
  Widget buildSearchField() => Expanded(
    child: TextField(
      controller: fieldController,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(Icons.plus_one),
          onPressed: () {
            if (widget.onTagBarChanged != null) {
              //widget.onTagBarChanged!(ElevatedButton(onPressed: () {}, child: const Text("Test")));
              widget.onTagBarChanged!(Tag(name: fieldController.text, onDeleted: widget.onTagDelete,));
            }
          }
        )
      ),
    ),
  );
}
