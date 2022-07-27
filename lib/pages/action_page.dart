import 'package:flutter/material.dart';
//widgets
import 'package:my_app/widgets/custom_tag_keyboard.dart';
import 'package:my_app/widgets/tag_bar.dart';
import 'package:my_app/widgets/animated_loading_button.dart';
import 'package:my_app/widgets/generic_snack_bar.dart';
import 'package:my_app/widgets/generic_search_field.dart' show MyTextFormField;
//data classes
import 'package:my_app/data_classes/tag_data.dart';
//connection
import 'package:my_app_mongo_api/my_app_api.dart' show MongoHubApp, AppException, ProductBuilder;
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
//parsers
import 'package:my_app/parsers/tag_parser.dart';
//other
import 'package:my_app/other/strings.dart' show ConnectionString, ActionPageLines, TestUser;
import 'package:my_app/other/enums.dart' show ButtonState;
import 'package:my_app/other/wrapper.dart';
import 'package:my_app/other/app_shared_preferences.dart' show AppSharedPreferences;
import 'dart:async';


class ActionPage extends StatefulWidget {
  const ActionPage({Key? key}) : super(key: key);

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  // button
  Wrapper<ButtonState> buttonState = Wrapper<ButtonState>(ButtonState.init);
  void _update(Function f) => setState(() => f);
  Future<bool> whileLoading() async {
    flag = true;
    while (flag) {await Future.delayed(const Duration(seconds: 1));}
    return done;
  }
  void whenDone(bool done){
    if (done) Navigator.pushReplacementNamed(context, "/search_page");
  }
  //keyboard
  bool customKeyboardIsActive = false;

  //controllers
  final nameController = TextEditingController();
  final numController = TextEditingController();
  final commentController = TextEditingController();

  //connection
  MongoHubApp? mongoHub;
  Map<String, List<TagData>> allTags = {};
  final tagData = <TagData>[];
  //bool
  bool flag = false; bool done = false;
  bool disabled = false; bool turnOffButton = false;

  //sharedPreferences
  ObjectId userId = ObjectId.fromHexString(TestUser.hexString);
  final AppSharedPreferences sharedPreferences = AppSharedPreferences();
  Future getSharedPreferences() async {
    await sharedPreferences.init();
    userId = sharedPreferences.getUserObjectId() ?? ObjectId.fromHexString(TestUser.hexString);
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
  }

  Future openDatabase() async { // Open database and created if has not been created
    if (mongoHub == null){
      try{
        while(!sharedPreferences.isLive && mounted) {await Future.delayed(const Duration(milliseconds: 1));}
        mongoHub = await MongoHubApp.create(URL: ConnectionString.url, hexId: userId.toHexString());
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
      print("Unaccounted Exception");
      rethrow;
    }
  }
  Future loadAllData() async{
    try {
      await openDatabase();
      allTags = parseAllTags(await mongoHub!.tags.findAll(), await mongoHub!.tags.sortGroups());
      setState((){});
      while (true){
        while (true && !flag) {
          await Future.delayed(const Duration(seconds: 1));
        }
        if (await mongoHub!.foordProducts.existsName(nameController.text)){
            showActionSnackBar(context, ActionPageLines.productAlreadyExists, 3);
            flag = false;
        }
        else {
          final product = ProductBuilder();
          product.setName(nameController.text);
          for (final tag in tagData) {product.addTag(tag.id);}
          product.addRate(ObjectId.fromHexString("6241dd1232adfc92ac741177"),
              comment: commentController.text != "" ? commentController.text : null,
              rate: numController.text != "" ? int.parse(numController.text) : null);
          done = await mongoHub!.foordProducts.addJson(product.returnJson());
          flag = false;
          if (done) break;
          if (!done) showActionSnackBar(context, ActionPageLines.somethingWentWrong, 3);
        }
      }
      await closeDatabase();
    } on AppException {
      allTags = {};
      return;
    }
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }


  @override
  void initState() {
    super.initState();

    getSharedPreferences();
    loadAllData();
  }
  @override
  void setState(VoidCallback fn){
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            title: const Text(ActionPageLines.createNewPageName),
          leading: IconButton(
            icon : const Icon(Icons.keyboard_return_outlined),
            onPressed: () => Navigator.pushReplacementNamed(context, "/search_page"),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: <Widget>[
            MyTextFormField(
                hintText: ActionPageLines.nameField,
                fieldController: nameController,
                disabled: disabled || customKeyboardIsActive,
                maxLength: 100,
                searchButton: IconButton(
                  icon : const Icon(Icons.keyboard),
                  onPressed: (){
                    if (!customKeyboardIsActive) FocusScope.of(context).unfocus();
                    customKeyboardIsActive = !customKeyboardIsActive;
                    setState((){});
                    },
                ),
              ), //Name Row
              const SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: TagBar(data: tagData, onDeleted: (TagData tag) {
                  tag.isSelected = false;
                  tagData.remove(tag);
                  setState(() {});
                }),), //Tag Row
              const SizedBox(height: 10),
              TextFormField(
                  decoration: const InputDecoration(
                    hintText: ActionPageLines.rateField
                  ),
                  controller: numController,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  readOnly: disabled || customKeyboardIsActive,
                  maxLength: 3,
                  validator: (value) {
                    if (value=="") {turnOffButton = true; return null;}
                    if (!isNumeric(value) || value == null) {turnOffButton = true; return "Недопустимое значение";}
                    if (0 > int.parse(value) || int.parse(value) > 10){
                      turnOffButton = true;
                      return "Число должно быть между 0 и 10";
                    }
                    turnOffButton = false;
                    return null;
                    },
                ),
              //num Row
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                    hintText: ActionPageLines.commentField
                ),
                readOnly: customKeyboardIsActive,
                controller: commentController,
                maxLength: 30,
              ), // comment Row
              buildAnimatedButton(state: buttonState, update: _update, whileLoading: whileLoading,
                  child: const Text("Сохранить"), disabled: turnOffButton, afterLoading: whenDone),
              //const Spacer(),
              (customKeyboardIsActive) ? SizedBox(
                  height: 300, child: TagKeyboard(onTagPressed: onTagPressed, data: allTags)
              ) : const SizedBox(),
            ],
          ),
      ),
    );
  }
}
