class StockActualQty {
  String? itemCode;
  double? actualQty;

  StockActualQty({
    this.itemCode,
    this.actualQty,
  });

  StockActualQty.fromJson(Map<String, dynamic> json) {
    itemCode = json['item_code'];
    actualQty = json['actual_qty'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['item_code'] = itemCode;
    data['actual_qty'] = actualQty;
    return data;
  }
}