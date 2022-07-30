import 'package:flutter/material.dart';
import 'package:my_app/data_classes/item_data.dart';
//widgets
import 'package:my_app/widgets/custom_tag_keyboard.dart';
import 'package:my_app/widgets/tag_bar.dart';
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
import 'package:my_app/other/app_shared_preferences.dart' show AppSharedPreferences;
import 'dart:async';


class ChangePage extends StatefulWidget {
  const ChangePage({Key? key}) : super(key: key);

  @override
  State<ChangePage> createState() => _ChangePageState();
}

class _ChangePageState extends State<ChangePage> {
  //keyboard
  bool customKeyboardIsActive = false;

  //ItemData
  late final ItemData itemData;
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
  Future _delete() async {
    turnOffButtons = true; deleteFlag = true;
    setState(() { });
    while (deleteFlag && mounted) {await Future.delayed(const Duration(milliseconds: 1));}
    turnOffButtons = false;
    if (done) Navigator.pop(context);
    setState(() { });
  }
  Future _save() async {
    turnOffButtons = true; saveFlag = true;
    setState(() { });
    while (saveFlag && mounted) {await Future.delayed(const Duration(milliseconds: 1));}
    turnOffButtons = false;
    if (done) Navigator.pop(context);
    setState(() { });
  }

  //controllers
  final nameController = TextEditingController();
  final numController = TextEditingController();
  final commentController = TextEditingController();
  Future setControllers() async {
    if (controllersSet) return;
    controllersSet = false;
    MapEntry<ItemData, Map<String, List<TagData>>> get = ModalRoute.of(context)!.settings.arguments as MapEntry<ItemData,Map<String, List<TagData>>>;
    itemData = get.key;
    if (mongoHub == null) {allTags = get.value;}
    else {
      if (!mongoHub!.isConnected()) {allTags = get.value;}
    }

    nameController.text = itemData.name;
    await awaitSharedPreferences();
    for (final rate in itemData.rates){
      if (rate.userName == userName){
        numController.text = (rate.rate != null) ? rate.rate.toString() : "";
        commentController.text = rate.comment ?? "";
        break;
      }
    }
    tagData = itemData.tags;
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
  bool saveFlag = false; bool deleteFlag = false; bool done = false;
  bool turnOffButtons = false; bool controllersSet = false;
  bool sharedPreferencesSet = false;
  bool flag() => saveFlag || deleteFlag;
  Future awaitFlags() async {
    while (mounted && !flag()) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
  }

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
      awaitControllersSet();
      while (mounted){
        await awaitFlags();
        if (deleteFlag){
          done = await _settleDeleteFlag();
          if (done) break;
        }
        if (saveFlag) {
          done = await _settleSaveFlag();
          if (done) break;
        }
      }
      await closeDatabase();
    } on AppException catch (e) {
      showActionSnackBar(context, e.exceptionMessage, 3);
      allTags = {};
      return;
    }
  }
  Future<bool> _settleDeleteFlag() async {
    if ((List<Rate>.from(itemData.rates)
      ..removeWhere((element) => element.userName == userName)).isNotEmpty) {
      showActionSnackBar(context, "Запись не может быть удалена, так как на ней присутствуют отзывы других людей", 3);
      deleteFlag = false;
      return false;
    }
    else {
      await mongoHub!.foodProducts.deleteByID(itemData.id);
      deleteFlag = false;
      return true;
    }
}
  Future<bool> _settleSaveFlag() async {
    bool result = false;
    itemData.name = nameController.text;
    if (itemData.rates.indexWhere((element) => element.userName == userName) != -1) {
      itemData.rates
          .firstWhere((element) => element.userName == userName)
          .rate = int.tryParse(numController.text);
      itemData.rates
          .firstWhere((element) => element.userName == userName)
          .comment = commentController.text;
      //itemData!.tags = tagData; unnecessary
    }
    else {
      itemData.rates.add(
          Rate(
              userName: userName,
              rate: int.tryParse(numController.text),
              comment: commentController.text
          ));
    }

    result = await mongoHub!.foodProducts.addJson(
        (await _itemDataToProductBuilder(itemData)).returnJson()
    );
    if (result) {
      result = await mongoHub!.foodProducts.deleteByID(itemData.id);
      if (!result) {saveFlag = false; throw AppException("Deletion failed");}
    }

    if (!result) showActionSnackBar(context, "Добавление провалилось", 3);
    saveFlag = false;
    return result;
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
            onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MyTextFormField(
                      hintText: ActionPageLines.nameField,
                      fieldController: nameController,
                      disabled: flag() || customKeyboardIsActive,
                      maxLength: 100,
                      searchButton: IconButton(
                        icon : const Icon(Icons.keyboard),
                        onPressed: !flag() ? (){
                          if (!customKeyboardIsActive) FocusScope.of(context).unfocus();
                          customKeyboardIsActive = !customKeyboardIsActive;
                          setState((){});
                        } : null,
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
                      readOnly: flag() || customKeyboardIsActive,
                      maxLength: 3,
                      validator: (value) {
                        if (value=="") {turnOffButtons = false; return null;}
                        if (!isNumeric(value) || value == null) {turnOffButtons = true; return "Недопустимое значение";}
                        if (0 > int.parse(value) || int.parse(value) > 10){
                          turnOffButtons = true;
                          return "Число должно быть между 0 и 10";
                        }
                        turnOffButtons = false;
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
                    Container(
                      height: 5,
                      color: Colors.blueGrey,
                    ),
                    buildCommentaryColumn(),
                    const SizedBox(height: 5,),
                    Row(
                      children: [
                        Flexible(child: buildDeleteButton(), flex : 1),
                        Flexible(child: buildSaveButton(), flex : 1)
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          (customKeyboardIsActive) ? SizedBox(
              height: 300, child: TagKeyboard(onTagPressed: onTagPressed, data: allTags)
          ) : const SizedBox(),
        ],
      ),
    );
  }
  // Building Widgets
  Widget buildDeleteButton() => ElevatedButton(
          onPressed: !turnOffButtons ? _delete : null,
          child: const Text("Удалить"),
          style: ElevatedButton.styleFrom(
          primary: Colors.red
        ),
      );
  Widget buildSaveButton() => ElevatedButton(
      onPressed: !turnOffButtons ? _save : null,
      child: const Text("Сохранить"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue
      ),
  );
  Widget buildCommentaryColumn() => Column(children:
  controllersSet ? itemData.rates.map((e) {
    if (e.userName == userName) {return const SizedBox();}
    return ListTile(
      title: Text(e.userName),
      subtitle: Text(
          (e.rate != null ? "Оценка : ${e.rate.toString()} \n" : "") +
              (e.comment != null ? "Комментарий : ${e.comment}" : "")
      ),
    );}).toList() : [const SizedBox()]
  );
}
