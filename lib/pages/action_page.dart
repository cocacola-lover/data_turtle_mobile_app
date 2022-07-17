import 'package:flutter/material.dart';
import 'package:my_app/widgets/custom_tag_keyboard.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:my_app/widgets/generic_search_field.dart' show SearchFieldV2;
import 'package:my_app/data_classes/tag_data.dart';
import 'package:my_app_mongo_api/my_app_api.dart' show MongoHubApp, AppException;
import 'package:my_app/parsers/tag_parser.dart';
import 'package:my_app/other/strings.dart' show ConnectionString, ConnectionProblems;
import 'package:my_app/other/enums.dart' show CustomKeyboard;
import 'dart:async';


class ActionPage extends StatefulWidget {
  const ActionPage({Key? key}) : super(key: key);

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  late StreamSubscription<bool> keyboardSubscription;
  FocusNode focusNode = FocusNode();
  CustomKeyboard state = CustomKeyboard.nothingIsShown;
  bool customKeyboardIsActive = false;

  MongoHubApp? mongoHub;
  Map<String, List<TagData>> allTags = {};
  final tagData = <TagData>[];

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

    loadAllData();
  }

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
  Future loadAllData() async{
    try {
      await openDatabase();
      allTags = parseAllTags(await mongoHub!.tags.findAll(), await mongoHub!.tags.sortGroups());
      await closeDatabase();
      setState((){});
    } on AppException {
      allTags = {};
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
        resizeToAvoidBottomInset: state == CustomKeyboard.nothingIsShown,
        body: Column(
          children: <Widget>[
            const Spacer(),
            SearchFieldV2(
              focusNode: focusNode,
              searchButton: IconButton(
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
            ),

            //ElevatedButton(onPressed: () =>print('1!!!!!!!!!!!!!!!!!focusNode updated: hasFocus: ${focusNode.hasPrimaryFocus}'), child: Text("Hey")),
            (state != CustomKeyboard.nothingIsShown) ? SizedBox(
                height: 300, child: TagKeyboard(onTagPressed: onTagPressed, data: allTags)
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
