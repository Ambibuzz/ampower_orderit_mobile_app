class Banner {
  String? name;
  String? bannerImage;
  String? routeTo;
  String? categoryOrItemName;
  String? doctype;

  Banner(
      {this.name,
      this.bannerImage,
      this.routeTo,
      this.categoryOrItemName,
      this.doctype});

  Banner.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    bannerImage = json['banner_image'];
    routeTo = json['route_to'];
    categoryOrItemName = json['category_or_item_name'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['banner_image'] = bannerImage;
    data['route_to'] = routeTo;
    data['category_or_item_name'] = categoryOrItemName;
    data['doctype'] = doctype;
    return data;
  }
}
