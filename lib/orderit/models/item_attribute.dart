// Item Attributes are used in variants code
class ItemAttribute {
  String? name;
  // String? variantOf;
  String? attribute;
  String? attributeValue;
  // int? numericValues;
  // double? fromRange;
  // double? increment;
  // double? toRange;
  // String? doctype;

  ItemAttribute({
    this.name,
    // this.variantOf,
    this.attribute,
    this.attributeValue,
    // this.numericValues,
    // this.fromRange,
    // this.increment,
    // this.toRange,
    // this.doctype,
  });

  ItemAttribute.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    // variantOf = json['variant_of'];
    attribute = json['attribute'];
    attributeValue = json['attribute_value'];
    // numericValues = json['numeric_values'];
    // fromRange = json['from_range'];
    // increment = json['increment'];
    // toRange = json['to_range'];
    // doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    // data['variant_of'] = variantOf;
    data['attribute'] = attribute;
    data['attribute_value'] = attributeValue;
    // data['numeric_values'] = numericValues;
    // data['from_range'] = fromRange;
    // data['increment'] = increment;
    // data['to_range'] = toRange;
    // data['doctype'] = doctype;
    return data;
  }
}
