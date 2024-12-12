class ItemTagCategory {
  String? name;

  ItemTagCategory({this.name});

  ItemTagCategory.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}
