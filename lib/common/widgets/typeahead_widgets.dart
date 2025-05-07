import 'package:flutter/material.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';

class TypeAheadWidgets {
  static Widget itemUi(String item, BuildContext context, {Color? textColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: Sizes.smallPaddingWidget(context) * 1.5,
            horizontal: displayWidth(context) < 600 ? 16 : 24,
          ),
          child: Text(
            key: Key(item),
            item,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  static List<String> getSuggestions(String query, List<String> list) {
    var matches = <String>[];
    matches.addAll(list);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
