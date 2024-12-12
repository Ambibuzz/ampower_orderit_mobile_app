import 'package:orderit/orderit/models/item_tag_name.dart';

class Taglist {
  List<Tag>? tagList;

  Taglist({this.tagList});

  Taglist.fromJson(Map<String, dynamic> json) {
    tagList = List.from(json['tag_list']).map((e) => Tag.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (tagList != null) {
      data['tag_list'] = tagList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tag {
  String? tagCategory;
  List<ItemTagName?>? tags;
  Tag({this.tagCategory, this.tags});
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagCategory: json['tag_category'],
      tags: json['tags'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tag_category'] = tagCategory;
    data['tags'] = tags;
    return data;
  }
}
