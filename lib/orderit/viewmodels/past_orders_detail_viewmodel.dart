import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class PastOrdersDetailViewModel extends BaseViewModel {
  var productsList = <Product>[];
  var salesOrderItems = <Product>[];

  Future getProducts(SalesOrder? salesOrder) async {
    setState(ViewState.busy);
    salesOrderItems.clear();
    productsList =
        await locator.get<FetchCachedDoctypeService>().fetchCachedItemData();
    if (salesOrder?.salesOrderItems?.isNotEmpty == true) {
      for (var i = 0; i < salesOrder!.salesOrderItems!.length; i++) {
        var soItem = salesOrder.salesOrderItems?[i];
        var product =
            productsList.firstWhere((e) => e.itemName == soItem?.itemname);
        salesOrderItems.add(product);
      }
    }
    setState(ViewState.idle);
    notifyListeners();
  }

  Future addItemToCart(Product item, BuildContext context) async {
    var product = productsList.firstWhere((e) => e.itemName == item.itemName);
    await OrderitWidgets.addToCart(product, context);
    notifyListeners();
  }

  Future createCart(SalesOrder? salesOrder, BuildContext context) async {
    setState(ViewState.busy);
    await create(salesOrder?.salesOrderItems, context);
    setState(ViewState.idle);
  }

  Future create(List<SalesOrderItems>? soItems, BuildContext context) async {
    var di = <Cart>[];
    var connectivityStatus = Provider.of<ConnectivityStatus>(context);
    if (soItems?.isNotEmpty == true) {
      for (var i = 0; i < soItems!.length; i++) {
        var e = soItems[i];
        var product =
            productsList.firstWhere((pro) => pro.itemName == e.itemname);
        var images = await locator
            .get<ItemsViewModel>()
            .getImages(e.itemcode, connectivityStatus);
        di.add(Cart(
            id: e.itemcode,
            itemName: e.itemname,
            quantity: e.qty == null ? 0 : e.qty!.toInt(),
            itemCode: e.itemcode,
            rate: e.rate,
            imageUrl: images != [] ? images[0].fileUrl : product.image));
      }
      di.forEach((draftItem) {
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
        CustomTheme.onPrimaryColorLight,
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CustomTheme.successColor,
            ),
      );
    }
  }
}
