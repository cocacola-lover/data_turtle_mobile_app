import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'package:my_app/data_classes/tag_data.dart' show TagData;
import 'package:my_app/other/strings.dart' show TagMapFields;

Map<String, List<TagData>> parceAllTags(List<Map<String, dynamic>> data){
  Map<String, List<TagData>> ans = {};

  for (var tag in data){
    if (!ans.keys.contains(tag[TagMapFields.groupName])){
      ans[tag[TagMapFields.groupName] as String] = <TagData>[];
    }
    ans[tag[TagMapFields.groupName] as String]
        .add(
            TagData(isSelected: false, id: tag[TagMapFields.id],
                label: tag[TagMapFields.tagName], group: 0)
            );
  }
}