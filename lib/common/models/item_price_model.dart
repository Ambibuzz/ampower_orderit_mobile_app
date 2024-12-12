class ItemPriceList {
  List<ItemPrice>? itemPriceList;
  ItemPriceList({this.itemPriceList});

  ItemPriceList.fromJson(Map<String, dynamic> json) {
    itemPriceList = List.from(json['item_price_list'])
        .map((e) => ItemPrice.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (itemPriceList != null) {
      data['item_price_list'] = itemPriceList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ItemPrice {
  String? name;
  String? itemCode;
  String? itemName;
  int? packingUnit;
  String? priceList;
  String? currency;
  String? customer;
  double? priceListRate;
  String? uom;

  ItemPrice({
    this.name,
    this.itemCode,
    this.itemName,
    this.packingUnit,
    this.priceList,
    this.currency,
    this.customer,
    this.priceListRate,
    this.uom,
  });

  ItemPrice.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    packingUnit = json['packing_unit'];
    priceList = json['price_list'];
    customer = json['customer'];
    currency = json['currency'];
    priceListRate = json['price_list_rate'];
    uom = json['uom'];
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['name'] = name;
    data['item_code'] = itemCode;
    data['item_name'] = itemName;
    data['packing_unit'] = packingUnit;
    data['price_list'] = priceList;
    data['currency'] = currency;
    data['customer'] = customer;
    data['price_list_rate'] = priceListRate;
    data['uom'] = uom;
    return data;
  }
}
