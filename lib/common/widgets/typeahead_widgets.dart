import 'package:flutter/material.dart';

class TypeAheadWidgets {
  static Widget itemUi(String item, BuildContext context, {Color? textColor}) {
    return ListTile(
      key: Key(item),
      title: Text(
        item,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
            ),
      ),
    );
  }

  static List<String> getSuggestions(String query, List<String> list) {
    var matches = <String>[];
    matches.addAll(list);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
