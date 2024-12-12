class ItemTagName {
  String? name;
  String? tagCategory;
  bool? isSelected;

  ItemTagName({this.name, this.tagCategory, this.isSelected = false});

  ItemTagName.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    tagCategory = json['tag_category'];
    isSelected = json['is_selected'];
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['name'] = name;
    data['tag_category'] = tagCategory;
    data['is_selected'] = isSelected;
    return data;
  }
}
