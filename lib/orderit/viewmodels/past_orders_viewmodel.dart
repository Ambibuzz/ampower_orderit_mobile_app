import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
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
  bool isSalesOrderLoading = false;
  var itemsList = <Product>[];
  String? statusTextSO = '';
  var productsList = <Product>[];
  Map<String, dynamic> imagesUrlMap = {};
  bool isImagesLoading = false;

  Future getProducts() async {
    setState(ViewState.busy);
    productsList =
        await locator.get<FetchCachedDoctypeService>().fetchCachedItemData();
    setState(ViewState.idle);
    notifyListeners();
  }

  void getSalesOrderItemsImages() {
    isImagesLoading = true;
    notifyListeners();
    if (salesOrderList.isNotEmpty) {
      for (var i = 0; i < salesOrderList.length; i++) {
        if (salesOrderList[i].salesOrderItems?.isNotEmpty == true) {
          var imageUrls = <String>[];
          for (var j = 0; j < salesOrderList[i].salesOrderItems!.length; j++) {
            var soItem = salesOrderList[i].salesOrderItems?[j];
            var product =
                productsList.firstWhere((e) => e.itemName == soItem?.itemname);
            if (product.image?.isNotEmpty == true) {
              imageUrls.add(product.image!);
            }
          }
          imagesUrlMap[salesOrderList[i].name ?? ''] = imageUrls;
          imageUrls = [];
        }
      }
    }
    isImagesLoading = false;
    notifyListeners();
  }

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

  Future getPastOrders(BuildContext context, List<dynamic> filters) async {
    isSalesOrderLoading = true;
    await Future.delayed(const Duration(milliseconds: 200));
    notifyListeners();
    salesOrderList = await locator
        .get<OrderitApiService>()
        .getSalesOrderList(filters, context);

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

    isSalesOrderLoading = false;
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
