import 'package:flutter/material.dart';
import 'package:my_app/data_classes/tag_data.dart';
import 'package:my_app/data_classes/item_data.dart';
import 'package:my_app/widgets/tag_bar.dart';
import 'package:my_app/widgets/custom_tag_keyboard.dart';
import 'package:my_app/widgets/generic_search_field.dart';
import 'package:my_app/widgets/suggestion_line.dart';
import 'package:my_app/widgets/generic_snack_bar.dart';
import 'package:my_app/widgets/loading_screen.dart';
import 'package:my_app/widgets/item_panel.dart';
import 'package:my_app/other/strings.dart' show ConnectionString, ConnectionProblems;
import 'package:my_app/parsers/tag_parser.dart';
import 'package:my_app/parsers/item_parser.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:async';
import 'package:my_app_mongo_api/my_app_api.dart' show MongoHubApp, AppException;
import 'package:mongo_dart/mongo_dart.dart' show ConnectionException, ObjectId;

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // keyboard controllers
  late StreamSubscription<bool> keyboardSubscription;
  bool searchInFocus = false;
  bool tagKeyboardIsShown = false;
  final tagData = <TagData>[];
  final fieldController = TextEditingController();
  //connection
  MongoHubApp? mongoHub;
  bool disabled = false;
  Map<String, List<TagData>> allTags = {};
  List<ItemData> results = [];
  //Queue
  MapEntry<String, List<ObjectId>>? inQueue;
  bool queueIsRunning = false;

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

    fieldController.addListener(() {
      //loadFilteredData();
      setState(() { });
      addToQueue();
    });

    establishConnection();
  }
  @override
  void setState(VoidCallback fn){
    if (mounted) super.setState(fn);
  }

  //connection
  Future openDatabase() async { // Open database and created if has not been created
    if (mongoHub == null){
      try{
        mongoHub = await MongoHubApp.create(URL: ConnectionString.url, hexId: "6241dd1232adfc92ac741177");
        await mongoHub!.open();
      } on AppException{
        mongoHub = null;
        rethrow;
      } on Exception {
        mongoHub = null;
        print("Unaccounted Exception");
        rethrow;
      }
    }
    else {
      try{
        await mongoHub!.open();
      } on AppException {
        rethrow;
      } on Exception {
        print("Unaccounted Exception");
        rethrow;
      }
    }
  }
  Future closeDatabase() async {
    try {
      mongoHub!.close();
    } on Exception {
      print("UnaccountedException close");
      rethrow;
    }
  }
  Future establishConnection() async {
    bool first = true;
    try {
      await openDatabase();
      await closeDatabase();
      disabled = false;
      loadAllData();
      return;
    } on AppException {
      if (first) {showActionSnackBar(context, ConnectionProblems.connectionLost, 3);}
      first = false; disabled = true;
      setState((){});
    }

    while (disabled && mounted) {
      await Future.delayed(const Duration(seconds: 3));
      try {
        await openDatabase();
        await closeDatabase();
        disabled = false;
      } on AppException {
        disabled = true;
        print("hey");
      }
    }
    setState((){});
    if (mounted) showActionSnackBar(context, ConnectionProblems.connectionFound, 2);

    loadAllData();
  }
  void loadAllData() async{
    try {
      await openDatabase();
      allTags = parseAllTags(await mongoHub!.tags.findAll(), await mongoHub!.tags.sortGroups());
      await closeDatabase();
      setState((){});
    } on AppException {
      allTags = {};
      establishConnection();
      return;
    } on ConnectionException {
      allTags = {};
      establishConnection();
      return;
    }
  }

  // queue
  Future runQueue() async {
    queueIsRunning = true;
    while (inQueue != null){
      var inQueueCopy = MapEntry(inQueue!.key, List<ObjectId>.from(inQueue!.value));
      inQueue = null;
      await newLoadFilteredData(inQueueCopy);
    }
    queueIsRunning = false; setState(() {});
  }
  void addToQueue() {
    inQueue = MapEntry(fieldController.text, TagData.getAllId(tagData));
    if (!queueIsRunning) runQueue();
  }

  Future newLoadFilteredData(MapEntry<String, List<ObjectId>> pair) async {
    if (fieldController.text.isEmpty && tagData.isEmpty) {results = []; return;}
    try {
      await openDatabase();
      if (inQueue == null){
      results = parseItems(
          await mongoHub!.foordProducts.findFiltered(
              stringFilter: pair.key,
              tags: pair.value
          ),
          await mongoHub!.tags.sortGroups()
      );} // getting results
      await closeDatabase();
    } on AppException {
      results = [];
      establishConnection();
      return;
    } on ConnectionException {
      results = [];
      establishConnection();
      return;
    }
  }

  void loadFilteredData() async {
    if (fieldController.text.isEmpty && allTags.isEmpty) {results = []; setState(() {}); return;}
    try {
      await openDatabase();
      results = parseItems(
          await mongoHub!.foordProducts.findFiltered(
              stringFilter: fieldController.text,
              tags: TagData.getAllId(tagData)
          ),
          await mongoHub!.tags.sortGroups()
      ); // getting results
      await closeDatabase();
      setState((){});
    } on AppException {
      results = [];
      establishConnection();
      return;
    } on ConnectionException {
      results = [];
      establishConnection();
      return;
    }
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
    setState((){});
    addToQueue();
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
              child: queueIsRunning ? LoadingPage() : ListView(
                shrinkWrap: true,
                children: results.map((result) => ItemPanel(data: result, userName: "Полина")).toList(),
              ),
            ),
            SizedBox(
              height: 30,
              child: TagBar(data: tagData, onDeleted: (TagData tag) {
                tag.isSelected = false;
                tagData.remove(tag);
                addToQueue();
                setState(() {});
              }),
            ),
            SearchField(
                onFocusChanged: onFocusChanged,
                keyboardIsShown: !tagKeyboardIsShown,
                fieldController: fieldController,
                disabled: disabled,
                secondButton: IconButton(
                    icon: const Icon(Icons.keyboard),
                    onPressed: disabled == false ? () {
                      tagKeyboardIsShown = !tagKeyboardIsShown;
                      searchInFocus = true;
                      setState(() {});
                    } : null
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
