import 'dart:convert';
import 'package:orderit/common/services/dialog_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/custom_alert_dialog.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/draft.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';

class DraftDetailViewModel extends BaseViewModel {
  Draft? draft;
  bool changedFlag = false;
  List<String> outOfStockItems = [];
  List<String> priceChangesItems = [];
  List<TextEditingController> quantityControllerList =
      <TextEditingController>[];

  Future createCart(BuildContext context) async {
    setState(ViewState.busy);
    await create(draft?.cartItems, context);
    setState(ViewState.idle);
  }

  Future clearCartAndAppend(BuildContext context) async {
    setState(ViewState.busy);
    await clearAndAppend(draft?.cartItems, context);
    setState(ViewState.idle);
  }

  Future clearAndAppend(List<Cart>? items, BuildContext context) async {
    var cart = items
        ?.map((e) => Cart(
            id: e.itemCode,
            itemName: e.itemName,
            quantity: e.quantity,
            itemCode: e.itemCode,
            rate: e.newRate,
            imageUrl: e.imageUrl))
        .toList();

    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var c1 = Cartlist.fromJson(json.decode(data['data']));
        var previousCart = c1.cartList;
        previousCart?.clear();
        cart?.forEach((cartItem) {
          previousCart?.add(cartItem);
        });

        flutterStyledToast(
          context,
          'Cart Cleared and Items Added to Cart',
          CustomTheme.toastMessageBgColor,
          textStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: displayWidth(context) < 600
                ? Sizes.fontSizeMobile
                : Sizes.fontSizeLargeDevice,
          ),
        );

        locator.get<CartPageViewModel>().clearAndAddAll(previousCart);
      }
    }
  }

  Future create(List<Cart>? draftItems, BuildContext context) async {
    var di = draftItems
        ?.map((e) => Cart(
            id: e.itemCode,
            itemName: e.itemName,
            quantity: e.quantity,
            itemCode: e.itemCode,
            rate: e.newRate,
            imageUrl: e.imageUrl))
        .toList();

    di?.forEach((draftItem) {
      if (locator
          .get<CartPageViewModel>()
          .existsInCart(locator.get<CartPageViewModel>().items, draftItem)) {
        locator.get<CartPageViewModel>().items.forEach((item) {
          if (draftItem.itemCode == item.itemCode) {
            locator.get<CartPageViewModel>().setQty(
                locator.get<CartPageViewModel>().items.indexOf(item),
                (item.quantity + draftItem.quantity).toString(),
                context,
                showToast: false);
          }
        });
      } else {
        locator.get<CartPageViewModel>().add(draftItem, context);
      }
    });
    flutterStyledToast(
      context,
      'Items Added to Cart',
      CustomTheme.toastMessageBgColor,
      textStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: displayWidth(context) < 600
            ? Sizes.fontSizeMobile
            : Sizes.fontSizeLargeDevice,
      ),
    );
  }

  Future initQuantityController() async {
    setState(ViewState.busy);
    quantityControllerList.clear();
    if (draft?.cartItems?.isNotEmpty == true) {
      //init controller and increment and decrement btn value to false
      for (var i = 0; i < draft!.cartItems!.length; i++) {
        quantityControllerList.add(TextEditingController());
      }
      //set text to quantity controller
      for (var i = 0; i < draft!.cartItems!.length; i++) {
        quantityControllerList[i].text =
            draft!.cartItems![i].quantity.toString();
      }
    }

    notifyListeners();
    setState(ViewState.idle);
  }

  Future updateDraft(Draft? d1) async {
    setState(ViewState.busy);
    draft = d1;
    setState(ViewState.idle);

    notifyListeners();
  }

  // increment quantity
  Future increment(int index, BuildContext context) async {
    var item = draft?.cartItems?[index];
    item?.quantity = item.quantity + 1;
    //save to hive
    //increment quantity in quantitycontroller list
    quantityControllerList[index].text = item!.quantity.toString();
    notifyListeners();
    // updateCart();
  }

  // decremnt quantity
  Future decrement(int index, BuildContext context) async {
    var item = draft?.cartItems?[index];
    if (item?.quantity == 1) {
      // showDialog(index);
      // remove(index);
    } else {
      item?.quantity--;
    }

    //save to hive
    //decrement quantity in quantitycontroller list
    quantityControllerList[index].text = item!.quantity.toString();

    notifyListeners();
    // updateCart();
  }

  Future removeDraftItemDialog(int index, BuildContext context) async {
    await CustomAlertDialog().alertDialog(
      'Remove Item!',
      'Are you sure you want to remove item ${draft?.cartItems?[index].itemName}',
      'Cancel',
      'Ok',
      () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      () async {
        debugPrint('Remove at $index');
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

  // remove cart item at index
  Future remove(int index, BuildContext context) async {
    draft?.cartItems?.removeAt(index);
    //save to hive
    await Future.delayed(const Duration(milliseconds: 50));
    notifyListeners();
  }

  // for reassigning quantity after removing item at particular index
  // for eg if i remove element at index 4 and there are total 7 items assign 5th item quantity to 4,6th item quantity to 5 etc
  void readjustQuantityControllerList(int index) {
    for (var i = index; i < draft!.cartItems!.length; i++) {
      debugPrint(
          'Readjusted ${i + 1} i.e ${quantityControllerList[i + 1].text}  to $i i.e ${quantityControllerList[i].text}');
      quantityControllerList[i].text = quantityControllerList[i + 1].text;
    }
    notifyListeners();
  }

  // set quantity at index
  void setQty(int index, String value, BuildContext context) {
    // quantityControllerList[index].text = value;
    draft?.cartItems?[index].quantity = int.parse(value);
    notifyListeners();
    //save to hive
    // updateCart();
  }

  Future updateDrafts() async {
    var total = 0.0;
    var drafts = <Draft>[];
    var data = locator.get<OfflineStorage>().getItem('draft');

    if (data['data'] != null) {
      var dl = Draftlist.fromJson(jsonDecode(data['data']));
      if (dl.draftList?.isNotEmpty == true) {
        drafts = dl.draftList!;
      }
    }

    if (draft?.cartItems?.isNotEmpty == true) {
      for (var draftItem in drafts) {
        if (draftItem.expiry == draft?.expiry) {
          var index = drafts.indexOf(draftItem);
          //update quantity with quantityContoller
          for (var i = 0; i < draft!.cartItems!.length; i++) {
            total = total +
                draft!.cartItems![i].rate! * draft!.cartItems![i].quantity;
            drafts[index].cartItems![i].quantity =
                draft!.cartItems![i].quantity;
          }
          drafts[index].totalPrice = total;
          draft?.totalPrice = total;
          drafts[index] = draft!;
        }
      }
    }
    var draftlist = Draftlist(draftList: drafts);

    await locator
        .get<OfflineStorage>()
        .putItem('draft', jsonEncode(draftlist.toJson()));
    // getCartItems();
    notifyListeners();
  }
}
