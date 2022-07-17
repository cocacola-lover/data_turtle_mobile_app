import 'package:flutter/material.dart';
import 'dart:async';
import 'package:my_app_mongo_api/my_app_api.dart' show MongoHubApp, AppException;
import 'package:mongo_dart/mongo_dart.dart' show ConnectionException, ObjectId;
import 'package:my_app/other/strings.dart' show ConnectionString, ConnectionProblems;

class TestPage2 extends StatefulWidget {
  const TestPage2({Key? key}) : super(key: key);

  @override
  State<TestPage2> createState() => _TestPage2State();
}

class _TestPage2State extends State<TestPage2> {
  MongoHubApp? key;

  void openDatabase() async{
    try{
    key = await MongoHubApp.create(URL: ConnectionString.url, hexId: "6241dd1232adfc92ac741177");
    await key!.open();
    await key!.close();
    } on Exception catch (e) {
      print(e.toString());
    }
    print("key");
  }

  @override
  void initState() {
    super.initState();
    openDatabase();
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("hey")
    );
  }
}
