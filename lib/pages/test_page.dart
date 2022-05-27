import 'package:flutter/material.dart';
import 'package:my_app/data_classes/tag_data.dart';
import 'package:my_app/widgets/tag_bar.dart';
import 'package:my_app/widgets/autocomplete_tag_field.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final tagData = <TagData>[];
  final fieldController = TextEditingController();

  Widget buildSearchField() => Expanded(
    child: TextField(
      controller: fieldController,
      decoration: InputDecoration(
          suffixIcon: IconButton(
              icon: Icon(Icons.plus_one),
              onPressed: () {
                tagData.insert(0, TagData(label: fieldController.text, group: 1, isSelected: true));
                setState(() {});
              }
          )
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 30,
            child: TagBar(data: tagData, onDeleted: (TagData tag) {
              tagData.remove(tag);
              setState(() {});
            }),
          ),
          buildSearchField(),
        ],
      ),
    );
  }

}
