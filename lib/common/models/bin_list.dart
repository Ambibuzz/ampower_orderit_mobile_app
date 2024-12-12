class BinList {
  List<Bin>? binList;

  BinList({this.binList});

  BinList.fromJson(Map<String, dynamic> json) {
    binList = List.from(json['bin_list']).map((e) => Bin.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (binList != null) {
      data['bin_list'] = binList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Bin {
  String? name;
  String? modified;
  String? warehouse;
  String? itemCode;
  double? actualQty;
  double? valuationRate;
  double? stockValue;

  Bin({
    this.name,
    this.modified,
    this.warehouse,
    this.itemCode,
    this.actualQty,
    this.valuationRate,
    this.stockValue,
  });

  Bin.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    modified = json['modified'];
    warehouse = json['warehouse'];
    itemCode = json['item_code'];
    actualQty = json['actual_qty'];
    valuationRate = json['valuation_rate'];
    stockValue = json['stock_value'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['modified'] = modified;
    data['warehouse'] = warehouse;
    data['item_code'] = itemCode;
    data['actual_qty'] = actualQty;
    data['valuation_rate'] = valuationRate;
    data['stock_value'] = stockValue;
    return data;
  }
}