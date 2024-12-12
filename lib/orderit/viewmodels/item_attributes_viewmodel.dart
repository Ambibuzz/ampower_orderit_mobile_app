import 'dart:convert';

import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/util/apiurls.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';

class ItemAttributesViewModel extends BaseViewModel {
  // variants
  List<Product> productsFromVariants = [];
  List<ItemsModel> itemFromVariants = [];
  List<Product> p1 = [];

  List<TextEditingController> quantityControllerList =
      <TextEditingController>[];

  List<Cart>? cartItems = [];

  void add(ItemsModel item, BuildContext context) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = Cart(
        id: item.itemCode,
        itemName: item.itemName,
        quantity: item.quantity,
        itemCode: item.itemCode,
        rate: item.price,
        imageUrl: item.images != [] ? item.images![0].fileUrl : item.imageUrl);

    if (cartPageViewModel.existsInCart(cartPageViewModel.items, cartItem)) {
      updateCartItems();
      await locator.get<ItemsViewModel>().updateCartItems();
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      //Increment quantity
      await cartPageViewModel.increment(index, context);
    } else {
      await cartPageViewModel.add(cartItem, context);
    }
    updateCartItems();
    await locator.get<ItemsViewModel>().updateCartItems();
    await cartPageViewModel.initQuantityController();
    notifyListeners();
  }

  void remove(ItemsModel item, BuildContext context, int itemQuantity) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = Cart(
        id: item.itemCode,
        itemName: item.itemName,
        quantity: item.quantity,
        itemCode: item.itemCode,
        rate: item.price,
        imageUrl: item.images != [] ? item.images![0].fileUrl : item.imageUrl);

    // when quantity reaches to 1 remove item from cart
    if (itemQuantity == 1) {
      // remove quantity from cart

      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      await cartPageViewModel.remove(index, context);
    }
    // decrement quantity until quantity reaches to 1
    else {
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      await cartPageViewModel.decrement(index, context);
    }
    updateCartItems();
    await locator.get<ItemsViewModel>().updateCartItems();
    await cartPageViewModel.initQuantityController();
    // await model.getCartItems();
  }

  Future initQuantityController() async {
    setState(ViewState.busy);
    var cartPageViewModel = locator.get<CartPageViewModel>();
    quantityControllerList.clear();
    if (itemFromVariants.isNotEmpty) {
      //init controller
      for (var i = 0; i < itemFromVariants.length; i++) {
        quantityControllerList.add(TextEditingController());
      }
      //set text to quantity controller
      for (var i = 0; i < itemFromVariants.length; i++) {
        var item = itemFromVariants[i];
        var cartItemCodeList =
            cartPageViewModel.items.map((e) => e.itemCode).toList();
        // if exists in cart then fetch cart quantity and set it to field
        if (cartItemCodeList.contains(item.itemCode)) {
          var cartItem = cartPageViewModel.items
              .firstWhere((element) => element.itemCode == item.itemCode);
          var index = cartPageViewModel.items.indexOf(cartItem);
          var qty = cartPageViewModel.items[index].quantity;
          quantityControllerList[i].text = qty.toString();
        }
        //if doenst exist in cart init to 0
        else {
          quantityControllerList[i].text = 0.toString();
        }
      }
    }

    notifyListeners();
    setState(ViewState.idle);
  }

  void incrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val + 1;
    quantityControllerList[index].text = val.toString();
    notifyListeners();
  }

  void decrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val - 1;
    quantityControllerList[index].text = val.toString();
    notifyListeners();
  }

  Future setQty(int index, String value, BuildContext context) async {
    // quantityControllerList[index].text = value;
    // itemsList[index].quantity = int.parse(value);
    // update cart item
    var item = itemFromVariants[index];

    var cartPageViewModel = locator.get<CartPageViewModel>();
    var cartItemItemCodes =
        cartPageViewModel.items.map((e) => e.itemCode).toList();
    // if cart contains item then update cart
    if (cartItemItemCodes.contains(item.itemCode)) {
      var cartItem = cartPageViewModel.items
          .firstWhere((element) => element.itemCode == item.itemCode);
      var cartItemIndex = cartPageViewModel.items.indexOf(cartItem);
      cartPageViewModel.setQty(cartItemIndex, value, context);
    }
    // if cart doesnt contain item then add that item to cart
    else {
      await cartPageViewModel.add(
          Cart(
              id: item.itemCode,
              itemName: item.itemName,
              quantity: int.parse(value),
              itemCode: item.itemCode,
              rate: item.price,
              imageUrl: item.imageUrl),
          context);
    }

    await cartPageViewModel.initQuantityController();

    notifyListeners();
  }

  Future getVariants(ItemsModel item) async {
    // setState(ViewState.busy);

    if (item.itemCode != null) {
      p1 = await locator
          .get<ItemsService>()
          .getVariantsFromItemCode(item.itemCode);
      await getAttributesList();
      itemFromVariants = await locator
          .get<ItemsService>()
          .mapProductToItemModel(productsFromVariants);
      await getPricesForItemVarinats();
      await initQuantityController();
    } else {}
    notifyListeners();
    // setState(ViewState.busy);
  }

  Future getAttributesList() async {
    // setState(ViewState.busy);
    productsFromVariants.clear();
    var data = locator.get<OfflineStorage>().getItem(Strings.item);
    for (var i in p1) {
      // cached data is there then show cached item
      if (data['data'] != null) {
        var itemdata = jsonDecode(data['data']);
        var productList = ProductList.fromJson(itemdata);
        if (productList.productList != null) {
          var list = productList.productList!;
          var p = list.firstWhere((item) => item.itemCode == i.itemCode);
          productsFromVariants.add(p);
        }
        // product list is null
        else {}
      }
      // load from api
      else {
        var p =
            await locator.get<ItemsService>().getData(itemDataUrl(i.itemCode!));
        productsFromVariants.add(p);
      }
    }
    notifyListeners();
    // setState(ViewState.busy);
  }

  Future getPricesForItemVarinats() async {
    for (var i in itemFromVariants) {
      double price = await locator.get<ItemsService>().getPrice(i.itemCode!);
      var index = itemFromVariants.indexOf(i);

      itemFromVariants[index].price = price;
    }
    notifyListeners();
  }

  void updateCartItems() {
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          cartItems = cart.cartList!;
        }
      }
    }
    notifyListeners();
  }
}
