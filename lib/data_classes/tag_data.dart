import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class TagData{
  ObjectId id;
  String label;
  int group;
  bool isSelected;

  TagData({required this.label, required this.group, required this.isSelected, required this.id});
  TagData.empty(): id = ObjectId(), label = "", group = 0, isSelected = false;

  static TagData from(TagData value) {
    return TagData(label: value.label, group: value.group, isSelected: value.isSelected, id: ObjectId.fromHexString(value.id.toHexString()));
  }

  static List<ObjectId> getAllId(List<TagData> list){
    return list.map((value) => value.id).toList();
}
}
