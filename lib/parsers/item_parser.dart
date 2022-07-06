import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_app/data_classes/item_data.dart';
import 'package:my_app/other/strings.dart' show FoodProductMapFields, TagMapFields;
import 'package:my_app/data_classes/tag_data.dart';

List<ItemData> parseItems(List<Map<String, dynamic>> data, List<String> colors){
  List<ItemData> ans = [];

  for (var item in data){
    ans.add(ItemData(
        name: item[FoodProductMapFields.foodProductNameField] as String,
        rates: (item[FoodProductMapFields.foodProductRateField] as List<dynamic>)
            .map((value) => Rate(
          userName : (value as Map<String, dynamic>)[FoodProductMapFields.rateUserField] as String,
          rate : value[FoodProductMapFields.rateRateField] as int,
          comment: value[FoodProductMapFields.rateCommentField] as String?
        )).toList(),
        tags: (item[FoodProductMapFields.foodProductTagsField] as List<dynamic>)
        .map((value) => TagData(
            label: (value as Map<String, dynamic>)[TagMapFields.tagName] as String,
            group: colors.indexOf(value[TagMapFields.groupName]),
            isSelected: false
        )).toList(),
        id: item[FoodProductMapFields.foodProductIdField] as ObjectId
    ));
  }

  return ans;
}