import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:my_app/data_classes/tag_data.dart';

class ItemData{
  ObjectId id;
  String name;
  List<Rate> rates;
  List<TagData> tags;

  ItemData({required this.name, required this.rates, required this.tags, required this.id});
  ItemData.empty(): id = ObjectId(), name = "", rates = [], tags = [];
}

class Rate{
  String userName;
  int? rate;
  String? comment;

  Rate({this.rate, required this.userName, this.comment});
  Rate.empty(): rate = null, userName = "", comment = null;
}