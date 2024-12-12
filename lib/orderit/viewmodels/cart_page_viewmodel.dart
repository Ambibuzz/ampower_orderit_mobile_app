import 'dart:convert';

import 'package:orderit/common/models/item_price_model.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/custom_alert_dialog.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/customer_model.dart';
import 'package:orderit/orderit/models/draft.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/models/sales_order_model.dart';
import 'package:orderit/orderit/services/cart_service.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/common/services/dialog_service.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:ui' as ui;

class CartPageViewModel extends BaseViewModel {
  List<Cart> items = [];
  double total = 0;
  bool isVideo = false;
  List<TextEditingController> quantityControllerList =
      <TextEditingController>[];
  List<TextEditingController> quantityControllerListRec =
      <TextEditingController>[];
  String? customer;
  List<bool> incBtnPressed = [];
  List<bool> decBtnPressed = [];
  static const int btnPressDuration = 100;

  Set<int> selectedItems = Set();
  bool selectAll = false;
  List<ItemPrice> itemPriceList = [];

  Future getItemPrices() async {
    itemPriceList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedItemPriceData();
    notifyListeners();
  }

  void init() {
    selectedItems.clear();
    selectAll = false;
    notifyListeners();
  }

  void toggleSelectAll() async {
    selectAll = !selectAll;
    // select all items
    if (selectAll) {
      selectedItems.clear();
      for (var i = 0; i < items.length; i++) {
        selectedItems.add(i);
      }
    }
    // removed selected items
    else {
      selectedItems.clear();
    }
    notifyListeners();
  }

  void toggleSelected(bool isSelected, int index) async {
    if (isSelected) {
      selectedItems.remove(index);
      selectAll = false;
    } else {
      selectedItems.add(index);
    }
    if (selectedItems.length == items.length) {
      selectAll = true;
    }

    notifyListeners();
  }

  void removeSelectedItems(BuildContext context) async {
    // model.removeAll();
    // await model.showDialogToRemoveAllItems();
    var itemCodeList = <String?>[];
    // get item codes from selected items
    for (var element in selectedItems) {
      var itemCode = items[element].itemCode;
      itemCodeList.add(itemCode);
    }
    // remove selected items based on itemcodelist
    for (var element in itemCodeList) {
      var index = items.indexWhere((e) => e.itemCode == element);
      await remove(index, context);
      // for reassigning quantity at particular index
      readjustQuantityControllerList(index);
    }
    selectedItems.clear();
    notifyListeners();
  }

  Future addRec(ItemsModel item, BuildContext context) async {
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
      updateCart();
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      //Increment quantity
      await cartPageViewModel.increment(index, context);
    } else {
      await cartPageViewModel.add(cartItem, context);
    }
    // updateCartItems();
    // await locator.get<ItemsViewModel>().updateCartItems();
    updateCart();
    await cartPageViewModel.initQuantityController();
    notifyListeners();
  }

  Future addRecItemToCart(ItemsModel item, BuildContext context) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = Cart(
        id: item.itemCode,
        itemName: item.itemName,
        quantity: 1,
        itemCode: item.itemCode,
        rate: item.price,
        imageUrl: (item.images == null || item.images?.isEmpty == true)
            ? item.imageUrl
            : item.images![0].fileUrl);
    await add(cartItem, context);
    await cartPageViewModel.initQuantityController();
    notifyListeners();
  }

  Future removeRec(
      ItemsModel item, BuildContext context, int itemQuantity) async {
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
    updateCart();
    await cartPageViewModel.initQuantityController();
    // await model.getCartItems();
  }

  Future removeFromCartRec(ItemsModel item, BuildContext context) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    // remove quantity from cart
    var cartItemObj =
        cartPageViewModel.items.firstWhere((e) => e.itemCode == item.itemCode);
    var index = cartPageViewModel.items.indexOf(cartItemObj);
    await cartPageViewModel.remove(index, context);
    updateCart();
    await cartPageViewModel.initQuantityController();
  }

  void incrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val + 1;
    quantityControllerListRec[index].text = val.toString();
    notifyListeners();
  }

  void decrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val - 1;
    quantityControllerListRec[index].text = val.toString();
    notifyListeners();
  }

  void setIncBtnPressed(int index, bool value) {
    incBtnPressed[index] = value;
    notifyListeners();
  }

  void setDecBtnPressed(int index, bool value) {
    decBtnPressed[index] = value;
    notifyListeners();
  }

  Future getCustomer() async {
    setState(ViewState.busy);
    customer = locator.get<StorageService>().customerSelected;
    setState(ViewState.idle);
    notifyListeners();
  }

  Future initQuantityController() async {
    setState(ViewState.busy);
    quantityControllerList.clear();
    if (items.isNotEmpty) {
      //init controller and increment and decrement btn value to false
      for (var i = 0; i < items.length; i++) {
        quantityControllerList.add(TextEditingController());
        incBtnPressed.add(false);
        decBtnPressed.add(false);
      }
      //set text to quantity controller
      for (var i = 0; i < items.length; i++) {
        quantityControllerList[i].text = items[i].quantity.toString();
      }
    }

    notifyListeners();
    setState(ViewState.idle);
  }

  Future addQuantityController() async {
    quantityControllerList.add(TextEditingController());
    notifyListeners();
  }

  // set quantity at index
  void setQty(int index, String value, BuildContext context,
      {bool showToast = true}) {
    // quantityControllerList[index].text = value;
    items[index].quantity = int.parse(value);
    notifyListeners();
    //save to hive
    updateCart();
  }

  // get total amount of cart items
  void getTotal() {
    total = 0;
    for (var item in items) {
      // total = total + item.rate * item.quantity;
      var index = items.indexOf(item);
      total =
          total + item.rate! * int.parse(quantityControllerList[index].text);
    }

    notifyListeners();
  }

  //save cart to draft i.e wishlist
  //get previous drafts append current draft and save to hive db
  void saveToDraft(BuildContext context) async {
    if (items.isEmpty) {
      showSnackBar(
          'Cart is Empty Add Some Items in Cart to Save to Draft',
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          context);
    } else {
      // var draftMap = <String, dynamic>{};
      String? customerName = locator.get<StorageService>().customerSelected;
      var draft = Draft(
        customer: customerName,
        time: DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
        // time: DateFormat('yyyy-MM-dd hh:mm:ss')
        //     .parse('2024-09-08 011:31:00')
        //     .toString(),
        // expiry: DateFormat('yyyy-MM-dd hh:mm:ss')
        //     .parse('2024-09-13 011:31:00')
        //     .toString(),
        expiry: DateFormat('yyyy-MM-dd hh:mm:ss')
            .format(DateTime.now().add(const Duration(days: 5))),
        // expiry: DateFormat('yyyy-MM-dd hh:mm:ss')
        //     .format(DateTime.now().add(Duration(hours: 10))),
        cartItems: items,
        totalPrice: total,
        id: const Uuid().v1(),
      );

      //get draftMap
      var data = locator.get<OfflineStorage>().getItem('draft');
      // data is not null means draft are there
      // fetch old drafts and add draft to draftlist
      if (data['data'] != null) {
        // fetch old drafts
        var drafts = Draftlist.fromJson(jsonDecode(data['data']));
        //store draft to old drafts
        var draftList = drafts.draftList;
        draftList?.add(draft);
        drafts = Draftlist(draftList: draftList);
        //update draftMap with current list
        await locator
            .get<OfflineStorage>()
            .putItem('draft', jsonEncode(drafts.toJson()));
      }
      // draft is empty insert draft and save it to hive db
      else {
        var draftlist = Draftlist(draftList: [draft]);
        await locator
            .get<OfflineStorage>()
            .putItem('draft', jsonEncode(draftlist.toJson()));
      }
      // showSnackBar('Save to Draft Successfully!', context);
      flutterStyledToast(context, 'Items saved as draft',
          Theme.of(context).colorScheme.onPrimary,
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CustomTheme.successColor,
              ));
      // remove cart items after draft is created
      removeAll();
    }

    notifyListeners();
  }

  // display cart items from hive db to cart page
  Future setCartItems() async {
    setState(ViewState.busy);
    //from hive
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      // var list = json.decode(data['data']);
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          items = cart.cartList!;
        }
      }
    }
    notifyListeners();
    setState(ViewState.idle);
  }

  // get cart items from hive db
  Future<List<Cart?>> getCartItems() async {
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      // var list = json.decode(data['data']);
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          items = cart.cartList!;
          return items;
        } else {
          return [];
        }
      }
    }
    return [];
  }

  // add item to cart
  Future add(Cart item, BuildContext context) async {
    // print('added');
    items.add(item);
    await Future.delayed(const Duration(milliseconds: 50));
    notifyListeners();
    //save to hive
    updateCart();
  }

  // add all items to cart
  void addAll(List<Cart> item) {
    items.addAll(item);
    //save to hive
    notifyListeners();
    updateCart();
  }

  // clear and append items to cart
  void clearAndAddAll(List<Cart>? item) {
    items.clear();
    if (item != null) {
      items.addAll(item);
    }
    //save to hive
    notifyListeners();
    updateCart();
  }

  // remove cart item at index
  Future remove(int index, BuildContext context) async {
    items.removeAt(index);
    //save to hive
    await Future.delayed(const Duration(milliseconds: 50));
    notifyListeners();
    updateCart();
  }

  // remove all cart items
  void removeAll() {
    items.clear();
    total = 0;
    //save to hive
    notifyListeners();
    updateCart();
  }

  // edit quantity of cart item
  void edit(int index, int quantity, BuildContext context) {
    items[index].quantity = quantity;
    quantityControllerList[index].text = items[index].quantity.toString();
    //save to hive
    notifyListeners();
    updateCart();
  }

  // increment quantity
  Future increment(int index, BuildContext context) async {
    setIncBtnPressed(index, true);
    var item = items[index];
    item.quantity = item.quantity + 1;
    //save to hive
    //increment quantity in quantitycontroller list
    quantityControllerList[index].text = item.quantity.toString();
    await Future.delayed(const Duration(milliseconds: btnPressDuration));
    setIncBtnPressed(index, false);
    notifyListeners();
    updateCart();
  }

  // increment quantity by passing cart item
  // used in items page + button to add item directly to cart
  Future incrementQuantityOfItem(Cart item, BuildContext context) async {
    item.quantity = item.quantity + 1;
    var index = items.indexOf(item);
    quantityControllerList[index].text = item.quantity.toString();
    await Future.delayed(const Duration(milliseconds: 10));

    notifyListeners();
    updateCart();
  }

  // check if item exists in cart
  bool existsInCart(List<Cart> state, Cart cartItem) {
    var found = false;
    for (var element in state) {
      if (element.itemCode == cartItem.itemCode) found = true;
    }
    return found;
  }

  // decremnt quantity
  Future decrement(int index, BuildContext context) async {
    setDecBtnPressed(index, true);
    // print('decremented');
    var item = items[index];
    if (item.quantity == 1) {
      // showDialog(index);
      // remove(index);
    } else {
      item.quantity--;
    }

    //save to hive
    //decrement quantity in quantitycontroller list
    quantityControllerList[index].text = item.quantity.toString();
    await Future.delayed(const Duration(milliseconds: btnPressDuration));
    setDecBtnPressed(index, false);
    notifyListeners();
    updateCart();
  }

  Future showSavetoDraftDialog(
      CartPageViewModel model, BuildContext context) async {
    await CustomAlertDialog().alertDialog(
      'You are Offline!',
      'Do you want to save cart to Wishlist',
      'Cancel',
      'Ok',
      () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      () {
        model.saveToDraft(context);
        Navigator.of(context, rootNavigator: true).pop();
      },
      context,
    );
    notifyListeners();
  }

  // for reassigning quantity after removing item at particular index
  // for eg if i remove element at index 4 and there are total 7 items assign 5th item quantity to 4,6th item quantity to 5 etc
  void readjustQuantityControllerList(int index) {
    for (var i = index; i < items.length; i++) {
      debugPrint(
          'Readjusted ${i + 1} i.e ${quantityControllerList[i + 1].text}  to $i i.e ${quantityControllerList[i].text}');
      quantityControllerList[i].text = quantityControllerList[i + 1].text;
    }
    notifyListeners();
  }

  Future showDialogToRemoveSingleItem(int index, BuildContext context) async {
    await CustomAlertDialog().alertDialog(
      'Are You Sure?',
      'Do you want to remove item ${items[index].itemName} from cart?',
      'Cancel',
      'Remove',
      () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      () async {
        // remove cart item
        await remove(index, context);
        // for reassigning quantity at particular index
        readjustQuantityControllerList(index);
        Navigator.of(context, rootNavigator: true).pop();
      },
      context,
    );
    notifyListeners();
  }

  Future showDialogToRemoveAllItems(BuildContext context) async {
    await CustomAlertDialog().alertDialog(
      'Heads Up! Cart is about to get Clear',
      'Just confirming - you\'re emptying your cart. Want to save anything for later?',
      'Cancel',
      'Clear All',
      () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      () {
        removeAll();
        Navigator.of(context, rootNavigator: true).pop();
      },
      context,
    );
  }

  void updateCart() {
    total = 0;
    var cartlist = Cartlist(cartList: items);
    for (var item in items) {
      //update quantity with quantityContoller
      total = total + item.rate! * item.quantity;
      // int index = items.indexOf(item);
      // total = total + item.rate * int.parse(quantityControllerList[index].text);
    }
    locator
        .get<OfflineStorage>()
        .putItem('cart', jsonEncode(cartlist.toJson()));
    getCartItems();
    notifyListeners();
  }

  Future postSalesOrder(List<Cart> items, BuildContext context) async {
    setState(ViewState.busy);
    var date = DateFormat('y-M-d').format(DateTime.now()).toString();
    var soitems = <SalesOrderItemsModel>[];
    var catalogue = locator.get<OfflineStorage>().getItem('catalogue');
    String? customerName = locator.get<StorageService>().customerSelected;

    var globalDefaults = await locator.get<CommonService>().getGlobalDefaults();
    var company = globalDefaults.defaultCompany;

    String? priceListName = catalogue['data']['pricelist'];
    var catalogConfigDefaultCurrency = globalDefaults.defaultCurrency;

    if (priceListName?.isNotEmpty == true) {
      var pl = locator.get<CommonService>().getPriceList(priceListName ?? '');
    }

    var customer = CustomerModel();
    var customers = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedCustomerData();
    if (customers.isNotEmpty) {
      customer = customers.firstWhere(
          (customer) =>
              customer.customerName ==
              locator.get<StorageService>().customerSelected,
          orElse: () => customer);
    }
    var customerDefaultCurrency = customer.defaultCurrency;

    items.map((cart) {
      soitems.add(SalesOrderItemsModel(
          itemcode: cart.itemCode,
          qty: cart.quantity.toDouble(),
          rate: cart.rate,
          deliverydate: date));
    }).toList();
    var salesOrderModel = SalesOrderModel(
      docstatus: 0,
      currency: customerDefaultCurrency,
      company: company,
      customer: customerName,
      transactiondate: date,
      ordertype: 'Sales',
      salesOrderItems: soitems,
      priceListCurrency: customerDefaultCurrency,
      priceList: priceListName,
    );

    var result = await locator
        .get<CartService>()
        .postSalesOrder(salesOrderModel, context);
    if (result) {
      //Clear cart after sales order saved
      removeAll();
    }
    setState(ViewState.idle);
    notifyListeners();
  }
}
