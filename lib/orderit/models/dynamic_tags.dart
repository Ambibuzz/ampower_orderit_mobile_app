class DynamicTags {
  String? tag;
  String? image;

  DynamicTags({
    this.tag,
    this.image,
  });

  DynamicTags.fromJson(Map<String, dynamic> json) {
    tag = json['tags'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tags'] = tag;
    data['image'] = image;
    return data;
  }
}