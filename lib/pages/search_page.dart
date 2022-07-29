import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
//widgets
import 'package:my_app/widgets/custom_tag_keyboard.dart';
import 'package:my_app/widgets/generic_search_field.dart' show SearchFieldV2;
import 'package:my_app/widgets/suggestion_line.dart';
import 'package:my_app/widgets/generic_snack_bar.dart';
import 'package:my_app/widgets/tag_bar.dart';
import 'package:my_app/widgets/loading_screen.dart';
import 'package:my_app/widgets/item_panel.dart';
// dataClasses
import 'package:my_app/data_classes/tag_data.dart';
import 'package:my_app/data_classes/item_data.dart';
//connection
import 'package:my_app_mongo_api/my_app_api.dart' show MongoHubApp, AppException;
import 'package:mongo_dart/mongo_dart.dart' show ConnectionException, ObjectId;
//parsers
import 'package:my_app/parsers/tag_parser.dart';
import 'package:my_app/parsers/item_parser.dart';
//other
import 'package:my_app/other/strings.dart' show ConnectionString, ConnectionProblems,
AppLines, Routes;
import 'package:my_app/other/enums.dart' show CustomKeyboard;
import 'package:my_app/other/app_shared_preferences.dart' show AppSharedPreferences;
import 'dart:async';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  //keyboard
  late StreamSubscription<bool> keyboardSubscription;
  final focusNode = FocusNode();
  final fieldController = TextEditingController();
  CustomKeyboard state = CustomKeyboard.nothingIsShown;
  bool customKeyboardIsActive = false;
  //connection
  MongoHubApp? mongoHub;
  Map<String, List<TagData>> allTags = {};
  final tagData = <TagData>[];
  bool disabled = false;
  List<ItemData> results = [];
  //Queue
  MapEntry<String, List<ObjectId>>? inQueue;
  bool queueIsRunning = false;
  bool flag = false;
  //SharedPreferences
  String userName = "TestUser";
  final AppSharedPreferences sharedPreferences = AppSharedPreferences();
  Future getSharedPreferences() async {
    await sharedPreferences.init();
    userName = sharedPreferences.getUserName() ?? "TestUser";
  }
  void goTo(String address) => Navigator.pushNamed(context, address);
  void leaveFor(String address) => Navigator.pushReplacementNamed(context, address);

  void onTagPressed(TagData tag){
    if (tag.isSelected == false){
      tag.isSelected = true;
      tagData.insert(0, tag);
    }
    else{
      tag.isSelected = false;
      tagData.remove(tag);
    }
    addToQueue();
    setState((){});
  }
  void onTagPressedAndDelete(TagData tag){
    if (tag.isSelected == false){
      tag.isSelected = true;
      tagData.insert(0, tag);
    }
    else{
      tag.isSelected = false;
      tagData.remove(tag);
    }
    fieldController.clear();
    setState((){});
    addToQueue();
  }

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    // Subscribe
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (state != CustomKeyboard.standardKeyboardIsShown && visible) {
        state = CustomKeyboard.standardKeyboardIsShown;
      } else if (state == CustomKeyboard.standardKeyboardIsShown && !visible){
        FocusScope.of(context).unfocus();
        state = CustomKeyboard.nothingIsShown;
        setState((){});
      }
      setState((){});
    });

    fieldController.addListener(() {
      addToQueue();
      setState((){});
    });

    getSharedPreferences();
    establishConnection();
  }
  @override
  void setState(VoidCallback fn){
    if (mounted) super.setState(fn);
  }

  // connection
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
      await mongoHub!.close();
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
      await loadAllData();
      return;
    } on AppException {
      if (first) {showActionSnackBar(context, ConnectionProblems.connectionLost, 3);}
      first = false; disabled = true;
      print("hey");
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

    await loadAllData();
  }
  Future loadAllData() async{
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
    await runQueue();
  }

  // queue
  void addToQueue() => flag = true;
  Future runQueue() async {
    await openDatabase();
    try {
      while (mounted) {
        while (flag == false && mounted) {
          await Future.delayed(const Duration(seconds: 1));
        }
        flag = false;
        if (fieldController.text.isEmpty && tagData.isEmpty) {results = []; setState((){}); continue;}
        setState(() => queueIsRunning = true);
        results = parseItems(
            await mongoHub!.foodProducts.findFiltered(
                stringFilter: fieldController.text,
                tags: TagData.getAllId(tagData)
            ),
            await mongoHub!.tags.sortGroups()
        );
        setState(() => queueIsRunning = false);
      }
      await closeDatabase();
    } on AppException {
      results = [];
      mongoHub = null;
      establishConnection();
      return;
    }
  }

  @override
  void dispose() {
    focusNode.dispose(); keyboardSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (state == CustomKeyboard.customKeyboardIsShown){
          state = CustomKeyboard.nothingIsShown;
          setState((){});
          return false;
        }
        return true;
      },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(AppLines.name),
            actions: [
              IconButton(
                  onPressed: () => leaveFor("/settings_page"),
                  icon: const Icon(Icons.settings))
            ],
          ),
          resizeToAvoidBottomInset: state == CustomKeyboard.nothingIsShown,
          body: Column(
            children: <Widget>[
              Expanded(
                child: queueIsRunning ? const LoadingPage() : ListView(
                  shrinkWrap: true,
                  children: results.map((result) => ItemPanel(data: result, userName: userName,
                    onTap: (ItemData value) => Navigator.pushNamed(context, Routes.changePage, arguments: ItemData.from(value)),
                  )).toList(),
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
              SearchFieldV2(
                disabled: disabled,
                fieldController: fieldController,
                focusNode: focusNode,
                secondButton: IconButton(
                  icon : const Icon(Icons.keyboard),
                  onPressed: (){
                    if (state == CustomKeyboard.customKeyboardIsShown)
                    {
                      state = CustomKeyboard.standardKeyboardIsShown;
                      focusNode.requestFocus();
                    }
                    else {
                      state = CustomKeyboard.customKeyboardIsShown;
                      //SystemChannels.textInput.invokeMethod('TextInput.hide');
                      FocusScope.of(context).unfocus();
                    }
                    setState((){});
                  },
                ),
                searchButton: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Navigator.pushNamed(context, "/action_page"),
                ),
              ),
              (state == CustomKeyboard.standardKeyboardIsShown && fieldController.text.isNotEmpty) ?
              SuggestionLine(
                  str: fieldController.text,
                  data: allTags, onTagPressed: onTagPressedAndDelete
              ) : const SizedBox(),

              (state != CustomKeyboard.nothingIsShown) ? SizedBox(
                  height: 300, child: TagKeyboard(onTagPressed: onTagPressed, data: allTags,)
              ) : const SizedBox(),
            ],
          ),
        ),
    );
  }
}
