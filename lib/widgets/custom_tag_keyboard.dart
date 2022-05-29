import 'package:flutter/material.dart';
import 'package:my_app/data_classes/tag_data.dart';

const _spacing = 5.0;


class TagKeyboard extends StatelessWidget {
  const TagKeyboard({Key? key, required this.onTagPressed, required this.data})
      : super(key: key);

  final ValueSetter<TagData> onTagPressed;
  final Map<String, List<TagData>> data;

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black12,
    child: ListView(
      padding: EdgeInsets.zero,
      children: data.entries.map((entry) => Column(
          children: [
            Align(
                child: Text(entry.key, style: const TextStyle(fontSize: 20)),
                alignment: Alignment.centerLeft
            ),
            Align(
              child: Wrap(
                spacing: _spacing,
                runSpacing: _spacing,
                children: entry.value.map((tag) => FilterChip(
                  showCheckmark: false,
                  label: Text(tag.label, style: const TextStyle(fontSize: 15)),
                  onSelected: (isSelected) => onTagPressed(tag),
                  selected: tag.isSelected,
                  backgroundColor: Colors.primaries[tag.group],
                )).toList(),
              ),
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 5)
          ],
        ),
      ).toList(),
    ),
  );
}
