import 'package:flutter/material.dart';
import 'package:my_app/data_classes/tag_data.dart';

class SuggestionLine extends StatelessWidget {
  final String str;
  final Map<String,List<TagData>> data;
  final ValueSetter<TagData> onTagPressed;
  final double height;


  const SuggestionLine({Key? key, required this.str, required this.data,
  required this.onTagPressed, this.height = 40})
      : super(key: key);

  List<TagData> filterData(){
    var ans = <TagData>[];
    for (var entry in data.values){
      for (var tag in entry){
        if (tag.label.toLowerCase().contains(str.toLowerCase())) ans.add(tag);
      }
    }
    return ans;
  }



  @override
  Widget build(BuildContext context) {
    var children = filterData().map((tag) => FilterChip(
      showCheckmark: false,
      label: Text(tag.label, style: const TextStyle(fontSize: 15)),
      onSelected: (isSelected) => onTagPressed(tag),
      selected: tag.isSelected,
      backgroundColor: Colors.primaries[tag.group],
    )).toList();
    return (children.isNotEmpty) ?
     Container(
       height: height,
      color: Colors.black12,
      child: ListView(
        padding: EdgeInsets.all(6),
        children: children,
      scrollDirection: Axis.horizontal,
      )
    ) : const SizedBox();
  }
}
