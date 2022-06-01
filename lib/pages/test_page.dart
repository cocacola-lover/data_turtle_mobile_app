import 'package:flutter/material.dart';
import 'package:my_app/data_classes/tag_data.dart';
import 'package:my_app/widgets/tag_bar.dart';
import 'package:my_app/widgets/custom_tag_keyboard.dart';
import 'package:my_app/widgets/generic_search_field.dart';
import 'package:my_app/widgets/suggestion_line.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  bool searchInFocus = false;

  bool tagKeyboardIsShown = false;
  final tagData = <TagData>[];
  final fieldController = TextEditingController();

  @override
  void initState(){
    super.initState();

    fieldController.addListener(() => setState(() {}));
  }



  void onFocusChanged(bool focus) {
    if (!focus) tagKeyboardIsShown = false;
    setState(() {searchInFocus = focus;});
  }

  final allTags = {
    "food" : [TagData(label: "apple", group: 1, isSelected: false),
              TagData(label: "meat", group: 1, isSelected: false),
              TagData(label: "cucumber", group: 1, isSelected: false)],
    "cars" : [TagData(label: "Nissan", group: 2, isSelected: false),
              TagData(label: "Nissan", group: 2, isSelected: false)],
    "drinks" : [TagData(label: "Cola", group: 3, isSelected: false),
                TagData(label: "Pepsi", group: 3, isSelected: false),
                TagData(label: "Apple juice", group: 3, isSelected: false),
                TagData(label: "Orange juice", group: 3, isSelected: false),
                TagData(label: "Tomato juice", group: 3, isSelected: false),
                TagData(label: "Beer", group: 3, isSelected: false),
                TagData(label: "Fanta", group: 3, isSelected: false),
                TagData(label: "Sprite", group: 3, isSelected: false),]
  };

  void onTagPressed(TagData tag){
    if (tag.isSelected == false){
      tag.isSelected = true;
      tagData.insert(0, tag);
    }
    else{
      tag.isSelected = false;
      tagData.remove(tag);
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: !searchInFocus,
      body: Column(
        children: [
          const TextField(),
          const Spacer(),
          SizedBox(
            height: 30,
            child: TagBar(data: tagData, onDeleted: (TagData tag) {
              tag.isSelected = false;
              tagData.remove(tag);
              setState(() {});
            }),
          ),
          SearchField(
              onFocusChanged: onFocusChanged,
              keyboardIsShown: !tagKeyboardIsShown,
              fieldController: fieldController,
              secondButton: IconButton(
                  icon: const Icon(Icons.keyboard),
                  onPressed: () {
                    tagKeyboardIsShown = !tagKeyboardIsShown;
                    setState(() {});
                  }
              ),
              searchButton: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ),
          (!tagKeyboardIsShown && searchInFocus && fieldController.text.isNotEmpty) ?
          SuggestionLine(
                str: fieldController.text,
                data: allTags, onTagPressed: onTagPressed
          ) : const SizedBox(),
          (searchInFocus) ? SizedBox(
            height: 300, child: TagKeyboard(onTagPressed: onTagPressed, data: allTags)
          ) : const SizedBox(),
        ],
      ),
    );
  }

}
