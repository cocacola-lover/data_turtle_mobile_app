import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class AppSharedPreferences {
  SharedPreferences? _sharedPreferences;
  bool isLive = false;

  static const _userId = "userId";
  static const _userName = "userName";

  Future init() async { _sharedPreferences = await SharedPreferences.getInstance(); isLive = true;}

  Future setUserObjectId(ObjectId user) async =>
        await _sharedPreferences!.setString(_userId, user.toHexString());
  ObjectId? getUserObjectId() {
    String? hexString = _sharedPreferences!.getString(_userId);
    return hexString != null ? ObjectId.fromHexString(hexString) : null;
  }

  Future setUserName(String userName) async =>
      await _sharedPreferences!.setString(_userName, userName);
  String? getUserName() => _sharedPreferences!.getString(_userName);
}