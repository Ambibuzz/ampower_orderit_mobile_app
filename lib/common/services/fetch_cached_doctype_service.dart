import 'dart:convert';

import 'package:orderit/common/models/bin_list.dart';
import 'package:orderit/common/models/currency_model.dart';
import 'package:orderit/common/models/item_price_model.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/customer_model.dart';
import 'package:orderit/orderit/models/item_group.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/models/quotation.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/enums.dart';

class FetchCachedDoctypeService {
  Future<List<Bin>> fetchCachedBinData() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.bin);
    if (data['data'] != null) {
      var itemdata = jsonDecode(data['data']);
      var binList = BinList.fromJson(itemdata);
      if (binList.binList != null) {
        return binList.binList!;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<CurrencyModel>> fetchCachedCurrencyData() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.currency);
    if (data['data'] != null) {
      var cdata = jsonDecode(data['data']);
      var clist = CurrencyList.fromJson(cdata);
      if (clist.currencyList != null) {
        return clist.currencyList!;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<CustomerModel>> fetchCachedCustomerData() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.customer);
    if (data['data'] != null) {
      var custdata = jsonDecode(data['data']);
      var customerModelList = CustomerModelList.fromJson(custdata);
      if (customerModelList.customerList != null) {
        return customerModelList.customerList!;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<String>> fetchCachedCustomerListData() async {
    var customerNameList = <String>[];
    var data = locator.get<OfflineStorage>().getItem(Strings.customerNameList);
    if (data['data'] != null) {
      var list = data['data'] as List;
      if (list.isNotEmpty) {
        list.forEach((e) {
          customerNameList.add(e as String);
        });
      } else {
        customerNameList = [];
      }
    }
    return customerNameList;
  }

  Future<List<String>> getCachedCustomerList(
      ConnectivityStatus connectivityStatus) async {
    var customerList = <String>[];
    try {
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        var data =
            locator.get<OfflineStorage>().getItem(Strings.customerNameList);
        // contains cached ampower config cached data
        if (data['data'] != null) {
          return await locator
              .get<FetchCachedDoctypeService>()
              .fetchCachedCustomerListData();
        }
        // if cached data is not present load data from api
        else {
          return await locator
              .get<DoctypeCachingService>()
              .getCustomerNameListApi();
        }
      } else {
        // offline
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedCustomerListData();
      }
    } catch (e) {
      exception(e, '', 'getCachedOrderitConfiguration');
    }
    return customerList;
  }

  Future<List<String>> fetchCachedFavoritesData() async {
    var favoritesList = <String>[];
    var data = locator.get<OfflineStorage>().getItem(Strings.favoritesList);
    if (data['data'] != null) {
      var list = data['data'] as List;
      if (list.isNotEmpty) {
        list.forEach((e) {
          favoritesList.add(e as String);
        });
      } else {
        favoritesList = [];
      }
    }
    return favoritesList;
  }

  Future<List<Product>> fetchCachedItemData() async {
    // await flutterSimpleToast(
    //     Colors.white, Colors.black, 'Loading Offline Cached Data');
    var data = locator.get<OfflineStorage>().getItem(Strings.item);
    if (data['data'] != null) {
      var itemdata = jsonDecode(data['data']);
      var productList = ProductList.fromJson(itemdata);
      if (productList.productList != null) {
        return productList.productList!;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<ItemsModel>> fetchCachedItemDataFromItemGroup(
      String itemGroupName, ConnectivityStatus connectivityStatus) async {
    var itemsList = <ItemsModel>[];
    var data = locator.get<OfflineStorage>().getItem(Strings.item);
    if (data['data'] != null) {
      var itemdata = jsonDecode(data['data']);
      var productList = ProductList.fromJson(itemdata);
      if (productList.productList != null) {
        var products = productList.productList!;

        var list = products
            .where((item) =>
                item.itemGroup == itemGroupName && item.variantOf == null)
            .toList();
        // map product to itemsmodel
        for (var i = 0; i < list.length; i++) {
          var images = await locator
              .get<ItemsViewModel>()
              .getImages(list[i].name, connectivityStatus);
          var item = ItemsModel(
            imageUrl: list[i].image,
            itemCode: list[i].itemCode,
            itemDescription: list[i].description,
            itemName: list[i].itemName,
            price: 0,
            quantity: 1,
            hasVariants: list[i].hasVariants,
            variantOf: list[i].variantOf,
            // attributes: list[i].attributes,
            itemGroup: list[i].itemGroup,
            images: images ?? [],
          );
          itemsList.add(item);
        }
        return itemsList;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<dynamic> fetchCachedItemGroupsData() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.itemGroupTree);
    if (data['data'] != null) {
      var itemdata = data['data'];
      if (itemdata != null) {
        return itemdata;
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  Future<List<ItemGroupModel>> fetchCachedItemGroupListData() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.itemGroupList);
    if (data['data'] != null) {
      var itemdata = jsonDecode(data['data']);
      var itemGroupList = ItemGroupList.fromJson(itemdata);
      if (itemGroupList.itemGroupList != null) {
        return itemGroupList.itemGroupList ?? [];
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<ItemPrice>> fetchCachedItemPriceData() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.itemPrice);
    if (data['data'] != null) {
      var itemdata = jsonDecode(data['data']);
      var itemPriceList = ItemPriceList.fromJson(itemdata);

      if (itemPriceList.itemPriceList != null) {
        // var customerItemPrices = itemPriceList.itemPriceList!
        //     .where((e) => e.priceList == pricelist)
        //     .toList();
        var customerItemPrices = itemPriceList.itemPriceList!;

        return customerItemPrices;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<ItemsModel>> fetchCachedItemItemsModelData() async {
    var itemsModel = <ItemsModel>[];
    var data = locator.get<OfflineStorage>().getItem(Strings.item);
    if (data['data'] != null) {
      var itemdata = jsonDecode(data['data']);
      var productList = ProductList.fromJson(itemdata);

      if (productList.productList != null) {
        var list = productList.productList;
        if (list != null) {
          for (var i = 0; i < list.length; i++) {
            var item = list[i];
            var itemModel = ItemsModel(
              itemCode: item.itemCode,
              itemName: item.itemName,
              imageUrl: item.image,
              hasVariants: item.hasVariants,
              variantOf: item.variantOf,
              // attributes: item.attributes,
              itemGroup: item.itemGroup,
            );
            itemsModel.add(itemModel);
          }
        }
        return itemsModel;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<Quotation>> fetchCachedQuotationData() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.quotation);
    if (data['data'] != null) {
      var sodata = jsonDecode(data['data']);
      var qolist = QuotationList.fromJson(sodata);
      if (qolist.quotationList != null) {
        return qolist.quotationList!;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<SalesOrder>> fetchCachedSalesOrderData() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.salesOrder);
    if (data['data'] != null) {
      var sodata = jsonDecode(data['data']);
      var solist = SalesOrderList.fromJson(sodata);
      if (solist.salesOrderList != null) {
        return solist.salesOrderList!;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }
}
