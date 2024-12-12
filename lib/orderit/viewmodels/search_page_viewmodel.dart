import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/item_group.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:provider/provider.dart';

class SearchPageViewModel extends BaseViewModel {
  List<ItemName> items = [];
  List<SearchItem> searchItemNames = [];
  List<SearchItem> searchItemCodes = [];
  List<SearchItem> currentSearchList = [];
  List<ItemGroupModel> itemGroups = [];
  List<SearchItem> searchItemsList = [];
  List<ItemCode> itemCodeList = [];
  String? dropdownText = 'Item Name';
  List<String> dropdownList = ['Item Code', 'Item Name'];
  String? itemFromBarcode;
  List<ItemName> itemsList = [];
  List<Product> productsList = [];
  List<Cart?> cartItems = [];
  List<bool> addToCartPressed = [];

  void setAddToCartPressed(int index, bool value) {
    addToCartPressed[index] = value;
    notifyListeners();
  }

  bool itemInCart(String item) {
    for (var i = 0; i < cartItems.length; i++) {
      if ((dropdownText == dropdownList[0]
              ? cartItems[i]?.itemCode
              : cartItems[i]?.itemName) ==
          item) {
        return true;
      }
    }
    return false;
  }

  Future getCartItems() async {
    cartItems = await locator.get<CartPageViewModel>().getCartItems();
    notifyListeners();
  }

  Future getItemsList(BuildContext context) async {
    setState(ViewState.busy);
    var itemsModelList = <ItemsModel>[];
    var items = <ItemName>[];
    items.clear();
    itemCodeList.clear();
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    itemsModelList =
        await locator.get<ItemsService>().getItemsList(connectivityStatus);
    productsList =
        await locator.get<FetchCachedDoctypeService>().fetchCachedItemData();

    for (var item in itemsModelList) {
      items.add(ItemName(item.itemName ?? '', item.imageUrl ?? ''));
      // itemCodeList.add(item.itemCode ?? '');
      itemCodeList.add(ItemCode(item.itemCode ?? '', item.imageUrl ?? ''));
    }
    itemsList = items;
    setState(ViewState.idle);
    notifyListeners();
  }

  // set dropdown text and current search list for viewing itemcode or item name based on dropdown selected
  void setText(String? value) {
    dropdownText = value;
    searchItemNames.clear();
    searchItemCodes.clear();

    if (dropdownText == dropdownList[1]) {
      currentSearchList.clear();
      for (var i in items) {
        searchItemNames.add(SearchItem(i.itemName, 'Products', image: i.image));
      }
      currentSearchList = searchItemNames;
    } else {
      currentSearchList.clear();
      for (var i in itemCodeList) {
        searchItemCodes.add(SearchItem(i.itemCode, 'Products', image: i.image));
      }
      currentSearchList = searchItemCodes;
    }

    // searchItemsList.clear();
    notifyListeners();
  }

  Future scanBarcodeFlutter() async {
    itemFromBarcode = '';
    // var result = await scanBarcode('#004297', 'Cancel', true, ScanMode.BARCODE);
    // itemFromBarcode =
    //     await locator.get<CommonService>().getItemFromBarcode(result);
    dropdownText = dropdownList[0];
    notifyListeners();
  }

  // get item code and item name list
  Future getItems() async {
    setState(ViewState.busy);
    searchItemsList.clear();
    searchItemNames.clear();
    searchItemCodes.clear();
    //TODO: these below 2 lines are used for assigning item code and item name
    // items = locator.get<ItemCategoryViewModel>().itemsList;
    // itemCodeList = locator.get<ItemCategoryViewModel>().itemCodeList;
    items = itemsList;
    itemCodeList = itemCodeList;
    for (var i in items) {
      searchItemNames.add(SearchItem(i.itemName, 'Products', image: i.image));
    }
    for (var i in itemCodeList) {
      searchItemCodes.add(SearchItem(i.itemCode, 'Products', image: i.image));
    }

    currentSearchList =
        dropdownText == dropdownList[1] ? searchItemNames : searchItemCodes;
    notifyListeners();
    setState(ViewState.idle);
  }

  // add search list based on search text
  void search(String searchText) {
    // clear search items
    searchItemsList.clear();
    addToCartPressed.clear();
    // if current search list is not empty then add search list items to searchitemslist based on search text
    if (currentSearchList.isNotEmpty) {
      for (var item in currentSearchList) {
        var itemLowerCase = item.item.toLowerCase();
        if (itemLowerCase.contains(searchText)) {
          // print(item.item);
          searchItemsList.add(item);
          addToCartPressed.add(false);
        }
      }
    }
    notifyListeners();
  }

  Future clear() async {
    searchItemsList.clear();
    notifyListeners();
  }
}

class SearchItem {
  final String item;
  final String type;
  final String image;

  SearchItem(this.item, this.type, {required this.image});
}

class ItemCode {
  final String itemCode;
  final String image;

  ItemCode(this.itemCode, this.image);
}

class ItemName {
  final String itemName;
  final String image;

  ItemName(this.itemName, this.image);
}
