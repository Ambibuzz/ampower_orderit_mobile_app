import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:orderit/common/models/bin_list.dart';
import 'package:orderit/common/models/currency_model.dart';
import 'package:orderit/common/models/item_price_model.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/models/stock_actual_qty.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/orderit/models/customer_model.dart';
import 'package:orderit/orderit/models/file_model.dart';
import 'package:orderit/orderit/models/item_group.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/orderit/services/orderit_api_service.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';

class DoctypeCachingService {
  Future reCacheDoctypes(ConnectivityStatus connectivityStatus) async {
    var doctypeCachingService = locator.get<DoctypeCachingService>();
    await Future.wait([
      doctypeCachingService.cacheSalesOrder(
          Strings.salesOrder, connectivityStatus),
      doctypeCachingService.cacheCustomer(Strings.customer, connectivityStatus),
      doctypeCachingService.cacheCurrency(Strings.currency, connectivityStatus),
      doctypeCachingService.cacheItem(Strings.item, connectivityStatus),
      doctypeCachingService.cacheBin(Strings.bin, connectivityStatus),
      doctypeCachingService.cacheFiles(Strings.files, connectivityStatus),
      doctypeCachingService.cacheItemPrice(
          Strings.itemPrice, connectivityStatus),
      cacheBin(Strings.bin, connectivityStatus),
      doctypeCachingService.cacheItemGroups(
          Strings.itemGroupTree, connectivityStatus),
      doctypeCachingService.cacheCustomerNameList(
          Strings.customerNameList, connectivityStatus),
    ]);
  }

  Future cacheBin(String doctype, ConnectivityStatus connectivityStatus) async {
    var binlist = await getBinListFromApi([], connectivityStatus);
    if (binlist.isNotEmpty) {
      await locator
          .get<OfflineStorage>()
          .putItem(doctype, jsonEncode(BinList(binList: binlist).toJson()));
    }
  }

  Future cacheDoctype(String doctype, int cacheDays,
      ConnectivityStatus connectivityStatus) async {
    var doctypeCachingService = locator.get<DoctypeCachingService>();
    var data = locator.get<OfflineStorage>().getItem(doctype);
    if (data['data'] == null) {
      // cache data
      if (doctype == Strings.salesOrder) {
        await doctypeCachingService.cacheSalesOrder(
            doctype, connectivityStatus);
      }
      // cache bin
      else if (doctype == Strings.bin) {
        await cacheBin(doctype, connectivityStatus);
      }
      // cache currency
      if (doctype == Strings.currency) {
        await doctypeCachingService.cacheCurrency(doctype, connectivityStatus);
      }
      // cache customer
      else if (doctype == Strings.customer) {
        await doctypeCachingService.cacheCustomer(doctype, connectivityStatus);
      }
      // cache item
      else if (doctype == Strings.item) {
        await doctypeCachingService.cacheItem(doctype, connectivityStatus);
      }
      // cache favorites
      else if (doctype == Strings.favoritesList) {
        await doctypeCachingService.cacheFavoritesList(
            doctype, [], connectivityStatus);
      }
      // cache files
      else if (doctype == Strings.files) {
        await doctypeCachingService.cacheFiles(doctype, connectivityStatus);
      }
      // cache item price
      else if (doctype == Strings.itemPrice) {
        await doctypeCachingService.cacheItemPrice(doctype, connectivityStatus);
      }
      // cache item groups
      else if (doctype == Strings.itemGroupTree) {
        await doctypeCachingService.cacheItemGroups(
            doctype, connectivityStatus);
      }
      // cache customer name list
      else if (doctype == Strings.customerNameList) {
        await doctypeCachingService.cacheCustomerNameList(
            doctype, connectivityStatus);
      }
    } else {
      if (data['timestamp'] != null) {
        var timestamp = data['timestamp'] as DateTime;
        var timeNow = DateTime.now();
        var difference = timeNow.difference(timestamp);
        if (difference.inDays > cacheDays) {
          // cache doctype
          var connectionStatus = await (Connectivity().checkConnectivity());
          if (connectionStatus == ConnectivityResult.none) {
            await flutterSimpleToast(
                Colors.white, Colors.black, 'Check your internet connection');
          } else if (connectionStatus == ConnectivityResult.mobile ||
              connectionStatus == ConnectivityResult.wifi) {
            // fetch doctype data and cache it
            if (doctype == Strings.salesOrder) {
              await doctypeCachingService.cacheSalesOrder(
                  doctype, connectivityStatus);
            }
            // cache bin
            else if (doctype == Strings.bin) {
              await cacheBin(doctype, connectivityStatus);
            } else if (doctype == Strings.customer) {
              await doctypeCachingService.cacheCustomer(
                  doctype, connectivityStatus);
            } else if (doctype == Strings.currency) {
              await doctypeCachingService.cacheCurrency(
                  doctype, connectivityStatus);
            } else if (doctype == Strings.item) {
              await doctypeCachingService.cacheItem(
                  doctype, connectivityStatus);
            } else if (doctype == Strings.files) {
              await doctypeCachingService.cacheFiles(
                  doctype, connectivityStatus);
            } else if (doctype == Strings.itemPrice) {
              await doctypeCachingService.cacheItemPrice(
                  doctype, connectivityStatus);
            } else if (doctype == Strings.itemGroupTree) {
              await doctypeCachingService.cacheItemGroups(
                  doctype, connectivityStatus);
            } else if (doctype == Strings.customerNameList) {
              await doctypeCachingService.cacheCustomerNameList(
                  doctype, connectivityStatus);
            } else {}
          }
        } else {
          // do nothing
        }
      }
    }
  }

  Future<List<Bin>> getBinListFromApi(
      List<dynamic> filters, ConnectivityStatus connectivityStatus) async {
    var list = [];
    var binlist = <Bin>[];
    var url = '/api/resource/Bin';
    var queryParams = {
      'fields':
          '["name","item_code","modified","warehouse","actual_qty","valuation_rate","stock_value"]',
      'limit_page_length': '*',
      'filters': jsonEncode(filters)
    };
    try {
      final response = await DioHelper.dio?.get(url,
          queryParameters: queryParams,
          options: Options(
            sendTimeout: const Duration(seconds: Sizes.timeoutDuration),
            receiveTimeout: const Duration(seconds: Sizes.timeoutDuration),
          ));
      if (response?.statusCode == 200) {
        var data = response?.data;
        list = data['data'];
        for (var listJson in list) {
          binlist.add(Bin.fromJson(listJson));
        }
        return binlist;
      }
    } catch (e) {
      exception(e, url, 'getBinListFromApi');
    }
    return binlist;
  }

  //for fetching bin list
  Future<List<Bin>> getBinList(
      List<dynamic> filters, ConnectivityStatus connectivityStatus) async {
    var list = [];
    var binlist = <Bin>[];
    var url = '/api/resource/Bin';
    var queryParams = {
      'fields':
          '["name","item_code","modified","warehouse","actual_qty","valuation_rate","stock_value"]',
      'limit_page_length': '*',
      'filters': jsonEncode(filters)
    };
    try {
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        var data = locator.get<OfflineStorage>().getItem(Strings.bin);
        // contains cached item cached data
        if (data['data'] != null) {
          return await locator
              .get<FetchCachedDoctypeService>()
              .fetchCachedBinData();
        }
        // if cached data is not present load data from api
        else {
          final response = await DioHelper.dio?.get(url,
              queryParameters: queryParams,
              options: Options(
                sendTimeout: const Duration(seconds: Sizes.timeoutDuration),
                receiveTimeout: const Duration(seconds: Sizes.timeoutDuration),
              ));
          if (response?.statusCode == 200) {
            var data = response?.data;
            list = data['data'];
            for (var listJson in list) {
              binlist.add(Bin.fromJson(listJson));
            }
            return binlist;
          } else {
            await showErrorToast(response);
          }
        }
      } else {
        // offline
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedBinData();
      }
    } catch (e) {
      exception(e, url, 'getBinList');
    }
    return binlist;
  }

  Future cacheCurrency(
      String doctype, ConnectivityStatus connectivityStatus) async {
    var clist = <CurrencyModel>[];
    clist = await locator
        .get<CommonService>()
        .getCurrencyList([], connectivityStatus);
    if (clist.isNotEmpty) {
      await locator.get<OfflineStorage>().putItem(
          doctype, jsonEncode(CurrencyList(currencyList: clist).toJson()));
      await showToast('${Strings.currency} synced ');
    }
  }

  Future cacheFavoritesList(String doctype, List<String>? favoritesList,
      ConnectivityStatus connectivityStatus) async {
    if (favoritesList?.isNotEmpty == true) {
      await locator.get<OfflineStorage>().putItem(doctype, favoritesList);
    } else {
      await locator.get<OfflineStorage>().putItem(doctype, []);
    }
  }

  Future cacheSalesOrder(
      String doctype, ConnectivityStatus connectivityStatus) async {
    var commonService = locator.get<CommonService>();
    var solist = <SalesOrder>[];
    var so = await locator
        .get<OrderitApiService>()
        .getSalesOrders([], connectivityStatus);
    for (var i = 0; i < so.length; i++) {
      var salesOrder = await commonService.getSalesOrder(
          Strings.salesOrder, so[i].name ?? '');
      solist.add(salesOrder);
    }
    if (so.isNotEmpty) {
      await locator.get<OfflineStorage>().putItem(
          doctype, jsonEncode(SalesOrderList(salesOrderList: solist).toJson()));
      await showToast('${Strings.salesOrder} synced ');
    }
  }

  Future cacheCustomer(
      String doctype, ConnectivityStatus connectivityStatus) async {
    var cust = await locator
        .get<OrderitApiService>()
        .getCustomers([], connectivityStatus);
    if (cust.isNotEmpty) {
      await locator.get<OfflineStorage>().putItem(
          doctype, jsonEncode(CustomerModelList(customerList: cust).toJson()));
      await showToast('${Strings.customer} synced ');
    }
  }

  Future cacheCustomerNameList(
      String doctype, ConnectivityStatus connectivityStatus) async {
    var cust = await getCustomerNameListApi();
    if (cust.isNotEmpty) {
      await locator.get<OfflineStorage>().putItem(doctype, cust);
      await showToast('${Strings.customerNameList} synced ');
    }
  }

  Future cacheItem(
      String doctype, ConnectivityStatus connectivityStatus) async {
    var items =
        await locator.get<OrderitApiService>().getItems([], connectivityStatus);
    await locator
        .get<OfflineStorage>()
        .putItem(doctype, jsonEncode(ProductList(productList: items).toJson()));
    // cache images
    var files = await getImages();
    await locator.get<OfflineStorage>().putItem(
        Strings.files, jsonEncode(FilesList(filesList: files).toJson()));
    await showToast('${Strings.item} synced ');
  }

  Future cacheFiles(
      String doctype, ConnectivityStatus connectivityStatus) async {
    var files = await getImages();
    if (files.isNotEmpty) {
      await locator
          .get<OfflineStorage>()
          .putItem(doctype, jsonEncode(FilesList(filesList: files).toJson()));
    }
  }

  Future<List<FileModelOrderIT>> getImages() async {
    var fileList = <FileModelOrderIT>[];
    var url = '/api/resource/File';
    var queryParams = {
      'fields': '["file_url","file_name","attached_to_name","is_private"]',
      'filters': '[["File","attached_to_doctype","=","Item"]]',
      'limit_page_length': '*'
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );
      if (response?.statusCode == 200) {
        var list = response?.data['data'] as List;
        for (var i = 0; i < list.length; i++) {
          String? fileurl = list[i]['file_url'];
          if (fileurl != null) {
            if (fileurl.endsWith('jpg') ||
                fileurl.endsWith('jpeg') ||
                fileurl.endsWith('png') ||
                fileurl.endsWith('webp') ||
                fileurl.endsWith('bmp') ||
                fileurl.endsWith('wbmp')) {
              fileList.add(FileModelOrderIT.fromJson(list[i]));
            }
          }
        }
        return fileList;
      }
    } catch (e) {
      exception(e, url, 'getImages');
    }
    return [];
  }

  Future cacheItemPrice(
      String doctype, ConnectivityStatus connectivityStatus) async {
    var items = await locator
        .get<OrderitApiService>()
        .getItemPrices([], connectivityStatus);
    if (items.isNotEmpty) {
      await locator.get<OfflineStorage>().putItem(
          doctype, jsonEncode(ItemPriceList(itemPriceList: items).toJson()));
      await showToast('${Strings.itemPrice} synced ');
    }
  }

  Future cacheItemGroups(
      String doctype, ConnectivityStatus connectivityStatus) async {
    print('inside cache item groups');
    // cache item group list and tree both
    var itemGroups = await locator.get<ItemsViewModel>().itemGroupTreeApi();
    var itemGroupsList = await locator.get<ItemsService>().itemGroupList();
    if (itemGroups != null) {
      print(itemGroups);
      await locator.get<OfflineStorage>().putItem(doctype, itemGroups);
      await showToast('${Strings.itemGroupTree} synced ');
    }
    if (itemGroupsList.isNotEmpty) {
      await locator.get<OfflineStorage>().putItem(Strings.itemGroupList,
          jsonEncode(ItemGroupList(itemGroupList: itemGroupsList).toJson()));
    }
  }

  Future<List<String>> getCustomerNameListApi() async {
    var url = '/api/resource/Customer';
    var queryParams = {
      'fields': '["customer_name"]',
      'limit_page_length': '*',
    };
    var customerNameList = <String>[];
    customerNameList = await locator.get<CommonService>().getDoctypeFieldList(
          url,
          'customer_name',
          queryParams,
        );
    return customerNameList;
  }

  Future<List<StockActualQty>> getStockActualQtyList() async {
    var stockActualQtyList = <StockActualQty>[];
    var binList =
        await locator.get<FetchCachedDoctypeService>().fetchCachedBinData();
    var itemCodeList = <String?>[];
    var uniqueItemCodeList = <String?>[];
    if (binList.isNotEmpty == true) {
      // get itemcode list
      for (var i = 0; i < binList.length; i++) {
        binList.map((e) => itemCodeList.add(e.itemCode)).toList();
      }
      // get unique itemcode list
      uniqueItemCodeList = itemCodeList.toSet().toList();
      // get stock actual qty list
      for (var i = 0; i < uniqueItemCodeList.length; i++) {
        var binListWithMatchingItemCode = binList
            .where((element) => element.itemCode == uniqueItemCodeList[i]);
        var totalPrice = 0.0;
        binListWithMatchingItemCode.forEach(
          (element) {
            totalPrice += element.actualQty!;
          },
        );
        stockActualQtyList.add(StockActualQty(
          itemCode: uniqueItemCodeList[i],
          actualQty: totalPrice,
        ));
      }
    }
    return stockActualQtyList;
  }

  Future showToast(String? message) async {
    await flutterSimpleToast(Colors.black, Colors.white, message ?? '');
  }
}
