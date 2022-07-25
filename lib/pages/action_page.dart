import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
import 'package:my_app/other/strings.dart' show ConnectionString, ActionPageLines;
import 'package:my_app/other/enums.dart' show CustomKeyboard, ButtonState;
import 'package:my_app/other/wrapper.dart';
import 'dart:async';


class ActionPage extends StatefulWidget {
  final bool isNew;
  const ActionPage({Key? key, required this.isNew}) : super(key: key);

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  // button
  Wrapper<ButtonState> buttonState = Wrapper<ButtonState>(ButtonState.init);
  void _update(Function f) => setState(() => f);
  Future<bool> whileLoading() async {
    flag = true;
    while (flag) {Future.delayed(const Duration(seconds: 1));}
    return done;
  }
  void whenDone(bool done){
    if (done) Navigator.pushReplacementNamed(context, "/search_page");
  }
  //keyboard
  late StreamSubscription<bool> keyboardSubscription;
  FocusNode focusNode = FocusNode();
  CustomKeyboard state = CustomKeyboard.nothingIsShown;
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
      //await closeDatabase();
      setState((){});
      while (mounted){
        while (mounted && !flag) {
          Future.delayed(const Duration(seconds: 1));
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
              rate: numController.text != "" ? int.parse(commentController.text) : null);
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
  @override
  void dispose() {
    closeDatabase();
    focusNode.dispose(); keyboardSubscription.cancel();
    super.dispose();
  }
  @override
  void setState(VoidCallback fn){
    if (mounted) super.setState(fn);
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
            title: widget.isNew ?
            const Text(ActionPageLines.createNewPageName) :
            const Text(ActionPageLines.editOldPageName),
          leading: IconButton(
            icon : const Icon(Icons.keyboard_return_outlined),
            onPressed: () => Navigator.pushReplacementNamed(context, "/search_page"),
          ),
        ),
        resizeToAvoidBottomInset: state == CustomKeyboard.nothingIsShown,
        body: Column(
          children: <Widget>[
            Row(
              children: [
                Flexible(
                    child: Container(
                      child: const Text(ActionPageLines.nameField),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0)
                     ),
                    flex: 1
                ),
                Flexible(child: MyTextFormField(
                  fieldController: nameController,
                  focusNode: focusNode,
                  disabled: disabled,
                  maxLength: 100,
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
                        FocusScope.of(context).unfocus();
                      }
                      setState((){});
                    },
                  ),
                ), flex: 3)
              ],
            ), //Name Row
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                    child: Container(
                        child: const Text(ActionPageLines.tagsField),
                        margin: const EdgeInsets.symmetric(horizontal: 20.0)
                    ),
                    flex: 1
                ),
                Flexible(child: SizedBox(
                  height: 30,
                  child: TagBar(data: tagData, onDeleted: (TagData tag) {
                    tag.isSelected = false;
                    tagData.remove(tag);
                    setState(() {});
                  }),
                ), flex: 3)
              ],
            ), //Tag Row
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                    child: Container(
                        child: const Text(ActionPageLines.rateField),
                        margin: const EdgeInsets.symmetric(horizontal: 20.0)
                    ),
                    flex: 1
                ),
                Flexible(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (hasFocus) {
                          state = CustomKeyboard.nothingIsShown;
                          setState(() {});
                        }
                      },
                      child: TextFormField(
                        controller: numController,
                        keyboardType: TextInputType.number,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        readOnly: disabled,
                        maxLength: 3,
                        validator: (value) {
                          if (value=="") {turnOffButton = true; setState(() { }); return null;}
                          if (!isNumeric(value) || value == null) {turnOffButton = true; setState(() { }); return "Недопустимое значение";}
                          if (0 > int.parse(value) || int.parse(value) > 10){
                            turnOffButton = true;
                            setState(() { });
                            return "Число должно быть между 0 и 10";
                          }
                          turnOffButton = false;
                          setState(() { });
                          return null;
                        },
                      ),
                    ),
                    flex: 3
                )
              ],
            ),  //num Row
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                    child: Container(
                        child: const Text(ActionPageLines.commentField),
                        margin: const EdgeInsets.symmetric(horizontal: 10.0)
                    ),
                    flex: 1
                ),
                Flexible(
                    child: TextFormField(
                      controller: commentController,
                      maxLength: 30,
                    ),
                    flex: 3
                )
              ],
            ), // comment Row
            buildAnimatedButton(state: buttonState, update: _update, whileLoading: whileLoading,
                child: const Text("Сохранить"), disabled: turnOffButton, afterLoading: whenDone),
            const Spacer(),
            (state != CustomKeyboard.nothingIsShown) ? SizedBox(
                height: 300, child: TagKeyboard(onTagPressed: onTagPressed, data: allTags)
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
