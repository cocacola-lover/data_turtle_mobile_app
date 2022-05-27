import 'package:flutter/material.dart';
import 'package:my_app/data_classes/tag_data.dart';

const double _spacing = 8;

class TagBar extends StatelessWidget {
  final List<TagData> data;
  final ValueChanged<TagData> onDeleted;

  const TagBar({Key? key, required this.data, required this.onDeleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
    children: data.map((tag) => InputChip(
      label: Text(tag.label),
      onDeleted: () => onDeleted(tag),
      backgroundColor: Colors.primaries[tag.group],
    )).toList(),
    scrollDirection: Axis.horizontal,
  );
}
