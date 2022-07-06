import 'package:flutter/material.dart';
import 'package:my_app/data_classes/item_data.dart';
import 'package:my_app/other/strings.dart' show ItemPanelStrings;
import 'package:marquee/marquee.dart';
import 'dart:math' show Random;

class ItemPanel extends StatelessWidget {
  const ItemPanel({Key? key,
    required this.data, required this.userName, this.onPressed}) : super(key: key);

  final ItemData data;
  final ValueGetter<ItemData>? onPressed;
  final String userName;

  @override
  Widget build(BuildContext context) {
    String? rate;
    String? comment;

    if (data.rates.isNotEmpty){
      double? score;
      for (final rate in data.rates){
        if (rate.userName == userName) {
          score = rate.rate.toDouble();
          comment = rate.comment;
        }
      }

      if (score != null) {rate = ItemPanelStrings.yourRating + score.toString();}
      else {
        score ??= data.rates.map((value) => value.rate).toList().reduce((a, b) => a + b) / data.rates.length;
        rate = ItemPanelStrings.averageRating + score.toString();
      }
      if (comment != null) {comment = ItemPanelStrings.yourComment + comment;}
      else {
        List<String?> cleanedList = data.rates.map((value) => value.comment).toList();
        cleanedList.removeWhere((element) => element == null);
        if (cleanedList.isNotEmpty) comment = ItemPanelStrings.randomComment + (cleanedList[Random().nextInt(cleanedList.length)] as String);
      }
    }

    return ListTile(
      onTap: () {},
      title: Container(child: Text(data.name), alignment: Alignment.centerLeft),
      subtitle: Column(
        children: [
          rate != null ?
          Container(child: Text(rate + "   " + (comment ?? "")), alignment: Alignment.centerLeft,) : const SizedBox(),
          data.tags.isNotEmpty ? Container(
            alignment: Alignment.centerLeft,
            height: 30,
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: data.tags.map((tag) => Chip(
                label: Text(tag.label),
                backgroundColor: Colors.primaries[tag.group],
              )).toList(),
              scrollDirection: Axis.horizontal,
            ),
          ) : const SizedBox(),
        ]
      ),
    );
  }
}
