class ItemGroupList {
  List<ItemGroupModel>? itemGroupList;
  ItemGroupList({this.itemGroupList});

  ItemGroupList.fromJson(Map<String, dynamic> json) {
    itemGroupList = List.from(json['item_group_list'])
        .map((e) => ItemGroupModel.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (itemGroupList != null) {
      data['item_group_list'] = itemGroupList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Item Group with image
class ItemGroupModel {
  final String? name;
  final String? image;

  ItemGroupModel({
    this.name,
    this.image,
  });

  factory ItemGroupModel.fromJson(Map<String, dynamic> json) {
    return ItemGroupModel(
      name: json['item_group_name'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['item_group_name'] = name;
    data['image'] = image;
    return data;
  }
}
