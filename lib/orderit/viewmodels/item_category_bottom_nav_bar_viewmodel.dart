import 'package:orderit/config/exception.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/item_group.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/orderit/views/cart_page_view.dart';
import 'package:orderit/orderit/views/draft_view.dart';
import 'package:orderit/orderit/views/items_view.dart';
import 'package:orderit/orderit/views/past_orders_view.dart';
import 'package:orderit/orderit/views/search_page_view.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemCategoryBottomNavBarViewModel extends BaseViewModel {
  List<ItemGroupModel> itemGroups = [];
  int currentIndex = 0;
  var pages = <Widget>[];

  void onItemTapped(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future getItemGroupsList(BuildContext context) async {
    setState(ViewState.busy);
    try {
      var connectivityStatus =
          Provider.of<ConnectivityStatus>(context, listen: false);
      itemGroups = await locator
          .get<ItemsService>()
          .getItemGroupList(connectivityStatus);
    } catch (e) {
      exception(e, 'getItemGroupsList', 'getItemGroupsList');
    } finally {
      setState(ViewState.idle);
    }

    notifyListeners();
  }

  void loadPages() {
    // List of pages
    pages = [
      if (itemGroups.isNotEmpty) ItemsView(itemGroup: itemGroups[0].name),
      SearchPageView(),
      const DraftView(),
      const PastOrdersView(),
      CartPageView(key: const Key(cartViewRoute)),
    ];
    notifyListeners();
  }
}
