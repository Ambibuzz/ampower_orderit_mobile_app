
class Cartlist {
  List<Cart>? cartList;

  Cartlist({this.cartList});

  Cartlist.fromJson(Map<String, dynamic> json) {
    cartList =
        List.from(json['cart_list']).map((e) => Cart.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (cartList != null) {
      data['cart_list'] = cartList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cart {
  int quantity = 0;
  String? id;
  String? itemName;
  String? itemCode;
  double? rate;
  double? newRate;
  String? imageUrl;

  Cart(
      {this.quantity = 0,
      this.id,
      this.itemName,
      this.rate = 0,
      this.newRate = 0,
      this.itemCode,
      this.imageUrl});

  Cart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemName = json['name'];
    quantity = json['quantity'];
    itemCode = json['itemcode'];
    rate = json['rate'] ?? 0;
    newRate = json['new_rate'] ?? 0;
    imageUrl = json['image_url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = itemName;
    data['quantity'] = quantity;
    data['itemcode'] = itemCode;
    data['rate'] = rate;
    data['new_rate'] = newRate;
    data['image_url'] = imageUrl;
    return data;
  }
}
