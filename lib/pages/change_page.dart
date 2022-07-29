import 'package:flutter/material.dart';
import 'package:my_app/data_classes/item_data.dart';
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


class ChangePage extends StatefulWidget {
  const ChangePage({Key? key}) : super(key: key);

  @override
  State<ChangePage> createState() => _ChangePageState();
}

class _ChangePageState extends State<ChangePage> {
  // button
  Wrapper<ButtonState> buttonState = Wrapper<ButtonState>(ButtonState.init);
  void _update(Function f) => setState(() => f);
  Future<bool> whileLoading() async {
    flag = true;
    while (flag) {await Future.delayed(const Duration(milliseconds: 3));}
    return done;
  }
  void whenDone(bool done){
    if (done) Navigator.pushReplacementNamed(context, "/search_page");
  }
  //keyboard
  bool customKeyboardIsActive = false;

  //ItemData
  ItemData? itemData;
  Future<ProductBuilder> _itemDataToProductBuilder(ItemData value) async {
    var ans = ProductBuilder();

    ans.setName(value.name);
    for (var rate in value.rates) {
      if (rate.rate == -1) rate.rate = null;
      if (rate.comment == "") rate.comment = null;

      ans.addRate(
          await mongoHub!.users.findIdByNameModern(rate.userName) as ObjectId,
          rate: rate.rate, comment: rate.comment
      );
    }
    for (final tag in value.tags) {ans.addTag(tag.id);}

    return ans;
  }

  //controllers
  final nameController = TextEditingController();
  final numController = TextEditingController();
  final commentController = TextEditingController();
  Future setControllers() async {
    if (itemData != null) return;
    controllersSet = false;
    itemData = ModalRoute.of(context)!.settings.arguments as ItemData;

    nameController.text = itemData!.name;
    await awaitSharedPreferences();
    for (final rate in itemData!.rates){
      if (rate.userName == userName){
        numController.text = rate.rate.toString();
        commentController.text = rate.comment ?? "";
        break;
      }
    }
    tagData = itemData!.tags;
    controllersSet = true;
    setState(() { });
  }
  Future awaitControllersSet() async {
    while(!controllersSet && mounted) {await Future.delayed(const Duration(milliseconds: 1));}
  }

  //connection
  MongoHubApp? mongoHub;
  Map<String, List<TagData>> allTags = {};
  List<TagData> tagData = <TagData>[];
  //bool
  bool flag = false; bool done = false;
  bool disabled = false; bool turnOffButton = false;
  bool controllersSet = false; bool sharedPreferencesSet = false;

  //sharedPreferences
  ObjectId userId = ObjectId.fromHexString(TestUser.hexString);
  String userName = TestUser.name;
  final AppSharedPreferences sharedPreferences = AppSharedPreferences();
  Future getSharedPreferences() async {
    await sharedPreferences.init();
    userId = sharedPreferences.getUserObjectId() ?? ObjectId.fromHexString(TestUser.hexString);
    userName = sharedPreferences.getUserName() ?? TestUser.name;
    sharedPreferencesSet = true;
  }
  Future awaitSharedPreferences() async {
    while(!sharedPreferences.isLive && mounted && !sharedPreferencesSet) {await Future.delayed(const Duration(milliseconds: 1));}
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
        await awaitSharedPreferences();
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
        if (await mongoHub!.foodProducts.existsName(nameController.text)){
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
          done = await mongoHub!.foodProducts.addJson(product.returnJson());
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
    //setControllers();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setControllers();
  }

  @override
  void setState(VoidCallback fn){
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(ActionPageLines.createNewPageName),
        leading: IconButton(
            icon : const Icon(Icons.keyboard_return_outlined),
            onPressed: () => Navigator.pop(context) //Navigator.pushReplacementNamed(context, "/search_page"),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7.0),
            child: Column(
              children: [
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
                      hintText: ActionPageLines.rateField,
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
              ],
            ),
          ),
          //buildAnimatedButton(state: buttonState, update: _update, whileLoading: whileLoading,
              //child: const Text("Сохранить"), disabled: true /*turnOffButton*/, afterLoading: whenDone),
          const Spacer(),
          (customKeyboardIsActive) ? SizedBox(
              height: 300, child: TagKeyboard(onTagPressed: onTagPressed, data: allTags)
          ) : const SizedBox(),
        ],
      ),
    );
  }
}
