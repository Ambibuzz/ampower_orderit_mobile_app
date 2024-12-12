import 'package:orderit/orderit/models/cart.dart';

class Draft {
  String? customer;
  String? time;
  String? expiry;
  List<Cart>? cartItems;
  double? totalPrice;
  String? id;

  Draft(
      {this.customer,
      this.time,
      this.expiry,
      this.cartItems,
      this.totalPrice,
      this.id});

  Draft.fromJson(Map<String, dynamic> json) {
    customer = json['customer'];
    time = json['time'];
    expiry = json['expiry'];
    // cartItems = json['cart_items'];
    totalPrice = json['total_price'];
    id = json['id'];
    if (json['cart_items'] != null) {
      cartItems = [];
      json['cart_items'].forEach((v) {
        cartItems!.add(Cart.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customer'] = customer;
    data['time'] = time;
    data['expiry'] = expiry;
    data['cart_items'] = cartItems;
    data['total_price'] = totalPrice;
    data['id'] = id;

    if (cartItems != null) {
      data['cart_items'] = cartItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Draftlist {
  List<Draft>? draftList;

  Draftlist({this.draftList});

  Draftlist.fromJson(Map<String, dynamic> json) {
    draftList =
        List.from(json['draft_list']).map((e) => Draft.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (draftList != null) {
      data['draft_list'] = draftList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
