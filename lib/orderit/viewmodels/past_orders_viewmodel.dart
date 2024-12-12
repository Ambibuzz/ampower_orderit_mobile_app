import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/services/orderit_api_service.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PastOrdersViewModel extends BaseViewModel {
  var salesOrderList = <SalesOrder>[];
  var itemsList = <Product>[];
  String? statusTextSO = '';

  void refresh() {
    notifyListeners();
  }

  void setStatusSO(String? status) {
    statusTextSO = status ?? '';
    notifyListeners();
  }

  Future addToCart(SalesOrder so, BuildContext context) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    if (so.salesOrderItems != null) {
      var cart = so.salesOrderItems?.map((e) {
        var item = itemsList.firstWhere(
          (element) => element.itemCode == e.itemcode,
        );
        return Cart(
            id: e.itemcode,
            itemName: e.itemname,
            quantity: e.qty!.toInt(),
            itemCode: e.itemcode,
            rate: e.rate,
            imageUrl: item.image);
      }).toList();
      cart?.forEach((cartItem) {
        if (locator
            .get<CartPageViewModel>()
            .existsInCart(cartPageViewModel.items, cartItem)) {
          var cartItemInCart = cartPageViewModel.items
              .firstWhere((element) => element.itemCode == cartItem.itemCode);
          var index = cartPageViewModel.items.indexOf(cartItemInCart);
          var totalQty = cartItem.quantity + cartItemInCart.quantity;
          cartPageViewModel.items.forEach((item) {
            if (cartItem.itemCode == item.itemCode) {
              cartPageViewModel.setQty(index, totalQty.toString(), context,
                  showToast: false);
            }
          });
        } else {
          locator.get<CartPageViewModel>().add(cartItem, context);
        }
      });
    }
    notifyListeners();
  }

  Future postSalesOrder(SalesOrder so, BuildContext context) async {
    if (so.salesOrderItems != null) {
      var cart = so.salesOrderItems?.map((e) {
        var item = itemsList.firstWhere(
          (element) => element.itemCode == e.itemcode,
        );
        return Cart(
            id: e.itemcode,
            itemName: e.itemname,
            quantity: e.qty!.toInt(),
            itemCode: e.itemcode,
            rate: e.rate,
            imageUrl: item.image);
      }).toList();
      await locator.get<CartPageViewModel>().postSalesOrder(cart!, context);
    }
  }

  Future getPastOrders(BuildContext context) async {
    setState(ViewState.busy);
    salesOrderList =
        await locator.get<OrderitApiService>().getSalesOrderList([], context);

    if (statusTextSO == '') {
      salesOrderList = salesOrderList
          .where((e) =>
              ((e.customer == locator.get<StorageService>().customerSelected)))
          .toList();
    } else {
      salesOrderList = salesOrderList
          .where((e) =>
              ((e.customer == locator.get<StorageService>().customerSelected) &&
                  e.status == statusTextSO))
          .toList();
    }

    setState(ViewState.idle);
    notifyListeners();
  }

  Future getItems(BuildContext context) async {
    setState(ViewState.busy);
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    itemsList = await locator.get<OrderitApiService>().getItemList([], context);
    setState(ViewState.idle);
    notifyListeners();
  }
}
