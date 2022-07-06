import 'package:flutter/material.dart';
import 'package:my_app/data_classes/tag_data.dart';
import 'package:my_app/data_classes/item_data.dart';
import 'package:my_app/widgets/tag_bar.dart';
import 'package:my_app/widgets/custom_tag_keyboard.dart';
import 'package:my_app/widgets/generic_search_field.dart';
import 'package:my_app/widgets/suggestion_line.dart';
import 'package:my_app/widgets/item_panel.dart';
import 'package:my_app/other/strings.dart' show ConnectionString;
import 'package:my_app/parsers/tag_parser.dart';
import 'package:my_app/parsers/item_parser.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:async';
import 'package:my_app_mongo_api/my_app_api.dart' show MongoHubApp;

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late StreamSubscription<bool> keyboardSubscription;

  bool searchInFocus = false;
  bool tagKeyboardIsShown = false;

  final tagData = <TagData>[];
  final fieldController = TextEditingController();

  late final MongoHubApp mongoHub;
  Map<String, List<TagData>> allTags = {};
  List<ItemData> results = [];

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (keyboardVisibilityController.isVisible == false && tagKeyboardIsShown == false && searchInFocus == true){
        searchInFocus = false;
        FocusNode().unfocus();
        setState((){});
      }
    });

    fieldController.addListener(() => setState(() {}));

    loadAllData();
  }
  //connection
  void loadAllData() async{
    mongoHub = await MongoHubApp.create(URL: ConnectionString.url, hexId: "6241dd1232adfc92ac741177");
    await mongoHub.open();

    allTags = parseAllTags(await mongoHub.tags.findAll(), await mongoHub.tags.sortGroups());
    results = parseItems(await mongoHub.foordProducts.findAll(), await mongoHub.tags.sortGroups());
    setState((){});
  }

  void onFocusChanged(bool focus) {
    if (!focus) tagKeyboardIsShown = false;
    setState(() {searchInFocus = focus;});
  }

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
    return WillPopScope(
      onWillPop: () async {
        if (tagKeyboardIsShown == true){
          tagKeyboardIsShown = false;
          setState((){});
          return false;
        }
        if (searchInFocus == true){
          searchInFocus = false;
          setState((){});
          return false;
        }
        setState((){});
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: !searchInFocus,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: results.map((result) => ItemPanel(data: result, userName: "Полина")).toList(),
              ),
            ),
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
                      searchInFocus = true;
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
      ),
    );
  }

}
