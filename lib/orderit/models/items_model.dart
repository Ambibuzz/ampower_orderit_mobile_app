import 'package:orderit/common/models/product.dart';
import 'package:orderit/orderit/models/file_model.dart';
import 'package:orderit/orderit/models/item_attribute.dart';

class ItemsModel {
  final String? itemName;
  final String? itemCode;
  int quantity;
  double price;
  // final String? currency;
  final String? itemDescription;
  final String? imageUrl;
  final int? hasVariants;
  final String? variantOf;
  final String? itemGroup;
  List<ItemAttribute>? attributes;
  List<ItemTags>? itemTags;
  List<FileModelOrderIT>? images;

  ItemsModel({
    this.itemName,
    this.itemCode,
    this.price = 0,
    this.quantity = 1,
    // this.currency,
    this.itemDescription,
    this.imageUrl,
    this.itemGroup,
    this.hasVariants,
    this.variantOf,
    this.attributes,
    this.itemTags,
    this.images,
  });

  factory ItemsModel.fromJson(Map<String, dynamic> json) {
    List<ItemAttribute>? attributeList = [];
    var itemTags = <ItemTags>[];

    if (json['attributes'] != null) {
      json['attributes'].forEach((v) {
        attributeList.add(ItemAttribute.fromJson(v));
      });
    }
    if (json['item_tags'] != null) {
      json['item_tags'].forEach((v) {
        itemTags.add(ItemTags.fromJson(v));
      });
    }
    return ItemsModel(
        itemName: json['item_name'] ?? '',
        itemCode: json['item_code'] ?? '',
        price: json['price_list_rate'] ?? 0,
        quantity: 1,
        // currency: json['currency'],
        itemDescription: json['item_description'],
        imageUrl: json['image'],
        hasVariants: json['has_variants'],
        variantOf: json['variant_of'],
        attributes: attributeList,
        itemTags: itemTags,
        itemGroup: json['item_group'],
        images: json['images']);
  }
}
