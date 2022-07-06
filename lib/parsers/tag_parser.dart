import 'package:my_app/data_classes/tag_data.dart' show TagData;
import 'package:my_app/other/strings.dart' show TagMapFields;

Map<String, List<TagData>> parseAllTags(List<Map<String, dynamic>> data, List<String> colors){
  Map<String, List<TagData>> ans = {};

  for (var tag in data){
    if (!ans.keys.contains(tag[TagMapFields.groupName])){
      ans[tag[TagMapFields.groupName] as String] = <TagData>[];
    }
    ans[tag[TagMapFields.groupName] as String]
        !.add(
            TagData(isSelected: false, id: tag[TagMapFields.id],
                label: tag[TagMapFields.tagName], group: 0)
            );
  }
  for (var list in ans.entries){
    for (var value in list.value) {value.group = colors.indexOf(list.key);}
  }

  return ans;
}