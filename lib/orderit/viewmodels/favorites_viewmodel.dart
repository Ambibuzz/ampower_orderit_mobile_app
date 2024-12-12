import 'dart:convert';

import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';

class FavoritesViewModel extends BaseViewModel {
  var favoriteItems = <ItemsModel>[];
  var favoritesList = <String>[];
  List<Cart?> cartItems = [];
  // quantity controller
  List<QuantityControllerModel> quantityControllerList =
      <QuantityControllerModel>[];
  bool isQuantityControllerInitialized = false;

  Future refresh() async {
    notifyListeners();
  }

  Future initQuantityController() async {
    setState(ViewState.busy);
    isQuantityControllerInitialized = false;
    var cartPageViewModel = locator.get<CartPageViewModel>();
    quantityControllerList.clear();

    if (favoriteItems.isNotEmpty) {
      //init controller & add to cart visible
      for (var i = 0; i < favoriteItems.length; i++) {
        quantityControllerList.add(QuantityControllerModel(
            favoriteItems[i].itemCode, TextEditingController()));
      }
      //set text to quantity controller
      for (var i = 0; i < favoriteItems.length; i++) {
        var item = favoriteItems[i];
        var cartItemCodeList =
            cartPageViewModel.items.map((e) => e.itemCode).toList();
        // if exists in cart then fetch cart quantity and set it to field
        if (cartItemCodeList.contains(item.itemCode)) {
          var cartItem = cartPageViewModel.items
              .firstWhere((element) => element.itemCode == item.itemCode);
          var index = cartPageViewModel.items.indexOf(cartItem);
          var qty = cartPageViewModel.items[index].quantity;
          quantityControllerList[i].controller?.text = qty.toString();
        }
        //if doenst exist in cart init to 0
        else {
          quantityControllerList[i].controller?.text = 0.toString();
        }
      }
    }
    isQuantityControllerInitialized = true;
    notifyListeners();
    setState(ViewState.idle);
  }

  Future add(ItemsModel item, BuildContext context) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = Cart(
        id: item.itemCode,
        itemName: item.itemName,
        quantity: item.quantity,
        itemCode: item.itemCode,
        rate: item.price,
        imageUrl: (item.images == null || item.images?.isEmpty == true)
            ? item.imageUrl
            : item.images![0].fileUrl);

    if (cartPageViewModel.existsInCart(cartPageViewModel.items, cartItem)) {
      updateCartItems();
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      //Increment quantity
      await cartPageViewModel.increment(index, context);
    } else {
      await cartPageViewModel.add(cartItem, context);
    }
    await updateCartItems();
    await cartPageViewModel.initQuantityController();
  }

  Future remove(ItemsModel item, BuildContext context, int itemQuantity) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = Cart(
        id: item.itemCode,
        itemName: item.itemName,
        quantity: item.quantity,
        itemCode: item.itemCode,
        rate: item.price,
        imageUrl: (item.images == null || item.images?.isEmpty == true)
            ? item.imageUrl
            : item.images![0].fileUrl);

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
    await updateCartItems();
    await cartPageViewModel.initQuantityController();
    // await model.getCartItems();
  }

  // set quantity at index
  Future setQty(int index, String value, BuildContext context) async {
    var item = favoriteItems[index];

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

  void incrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val + 1;
    quantityControllerList[index].controller?.text = val.toString();
    notifyListeners();
  }

  void decrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val - 1;
    quantityControllerList[index].controller?.text = val.toString();
    notifyListeners();
  }

  void updateQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val;
    quantityControllerList[index].controller?.text = val.toString();
    notifyListeners();
  }

  Future getCartItems() async {
    cartItems = await locator.get<CartPageViewModel>().getCartItems();
    notifyListeners();
  }

  Future getFavoritesItems() async {
    setState(ViewState.busy);
    favoriteItems.clear();
    favoritesList.clear();
    var items = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedItemItemsModelData();
    var favoritesItemCodeList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedFavoritesData();
    favoritesList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedFavoritesData();
    if (items.isNotEmpty && favoritesItemCodeList.isNotEmpty) {
      for (var i = 0; i < favoritesItemCodeList.length; i++) {
        favoriteItems.add(
            items.firstWhere((e) => e.itemCode == favoritesItemCodeList[i]));
      }
    }
    setState(ViewState.idle);
    notifyListeners();
  }

  bool isFavorite(String item) {
    if (favoritesList.contains(item)) {
      return true;
    } else {
      return false;
    }
  }

  bool itemInCart(String itemCode) {
    for (var i = 0; i < cartItems.length; i++) {
      if (cartItems[i]?.itemCode == itemCode) {
        return true;
      }
    }
    return false;
  }

  Future toggleFavorite(String item, BuildContext context) async {
    await locator.get<OrderitWidgets>().toggleFavorite(item, context);
    favoritesList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedFavoritesData();
    await getFavoritesItems();
    notifyListeners();
  }

  updateCartItems() {
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          cartItems = cart.cartList!;
        }
      }
      notifyListeners();
    }
  }
}
