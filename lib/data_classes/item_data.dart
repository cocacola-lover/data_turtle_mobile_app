import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:my_app/data_classes/tag_data.dart';

class ItemData{
  ObjectId id;
  String name;
  List<Rate> rates;
  List<TagData> tags;

  ItemData({required this.name, required this.rates, required this.tags, required this.id});
  ItemData.empty(): id = ObjectId(), name = "", rates = [], tags = [];

  static ItemData from(ItemData value){
    return ItemData(
        name: value.name,
        rates: value.rates.map((rate) => Rate.from(rate)).toList(),
        tags: value.tags.map((tag) => TagData.from(tag)).toList(),
        id: ObjectId.fromHexString(value.id.toHexString())
    );
  }


}

class Rate{
  String userName;
  int? rate;
  String? comment;

  Rate({this.rate, required this.userName, this.comment});
  Rate.empty(): rate = null, userName = "", comment = null;
  static Rate from(Rate value){
    return Rate(userName: value.userName, rate: value.rate, comment: value.comment);
  }
}