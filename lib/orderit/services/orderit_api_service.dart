import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:orderit/common/models/customer_doctype_model.dart';
import 'package:orderit/common/models/item_price_model.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/customer_model.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/orderit/services/customer_service.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderitApiService {
  //for fetching customer list
  Future<List<CustomerModel>> getCustomerList(
      List<dynamic> filters, BuildContext context) async {
    var list = [];
    var custlist = <CustomerModel>[];
    var url = '/api/resource/Customer';
    var queryParams = {
      'fields':
          '["name","customer_name","customer_group","default_currency","default_price_list","customer_primary_contact","mobile_no","email_id","customer_primary_address","primary_address","latitude_and_longitude"]',
      'limit_page_length': '*',
      'filters': jsonEncode(filters),
      'order_by': 'modified desc'
    };
    try {
      var connectivityStatus =
          Provider.of<ConnectivityStatus>(context, listen: false);
      //  online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        var data = locator.get<OfflineStorage>().getItem(Strings.customer);
        // if online and filter not empty then fetch from api
        if (filters.isNotEmpty) {
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
              custlist.add(CustomerModel.fromJson(listJson));
            }
            return custlist;
          }
        }
        // contains cached sales order display cached data
        if (data['data'] != null) {
          return await locator
              .get<FetchCachedDoctypeService>()
              .fetchCachedCustomerData();
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
              custlist.add(CustomerModel.fromJson(listJson));
            }
            return custlist;
          }
        }
      } else {
        // offline
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedCustomerData();
      }
    } catch (e) {
      exception(e, url, 'getCustomerList');
    }
    return custlist;
  }

  Future<List<CustomerModel>> getCustomers(
      List<dynamic> filters, ConnectivityStatus connectivityStatus) async {
    var list = [];
    var custlist = <CustomerModel>[];
    var url = '/api/resource/Customer';
    var queryParams = <String, dynamic>{};
    try {
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        queryParams = {
          'fields':
              '["name","customer_name","customer_group","default_currency","default_price_list","customer_primary_contact","mobile_no","email_id","customer_primary_address","primary_address"]',
          'limit_page_length': '*',
          'filters': jsonEncode(filters),
          'order_by': 'modified desc'
        };
      }
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
          custlist.add(CustomerModel.fromJson(listJson));
        }
        return custlist;
      } else {
        // offline
        await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedCustomerData();
      }
    } catch (e) {
      exception(e, url, 'getCustomerList');
    }
    return custlist;
  }

  Future<CustomerDoctype> getCustomerDoctype(String? customerName) async {
    try {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await DioHelper.dio?.get(
        '/api/method/frappe.desk.form.load.getdoc',
        queryParameters: {
          'doctype': 'Customer',
          'name': '$customerName',
          '_': '$timestamp'
        },
      );
      if (response?.statusCode == 200) {
        var data = response?.data;
        var cd = CustomerDoctype.fromJson(data);
        return cd;
      }
    } catch (e) {
      exception(e, '', 'getCustomerDoctype');
    }
    return CustomerDoctype();
  }

  //for fetching customer list
  Future<List<Product>> getItemList(
      List<dynamic> filters, BuildContext context) async {
    var list = [];
    var itemlist = <Product>[];
    var url = '/api/resource/Item';
    var queryParams = {
      'fields':
          '["name","item_code","item_name","item_group","stock_uom","description","shelf_life_in_days","warranty_period","image"]',
      'limit_page_length': '*',
      'filters': jsonEncode(filters)
    };
    try {
      var connectivityStatus =
          Provider.of<ConnectivityStatus>(context, listen: false);
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        var data = locator.get<OfflineStorage>().getItem(Strings.item);
        // contains cached item cached data
        if (data['data'] != null) {
          return await locator
              .get<FetchCachedDoctypeService>()
              .fetchCachedItemData();
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
              itemlist.add(Product.fromJson(listJson));
            }
            return itemlist;
          }
        }
      } else {
        // offline
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedItemData();
      }
    } catch (e) {
      exception(e, url, 'getItemList');
    }
    return itemlist;
  }

  //for fetching item price list
  Future<List<ItemPrice>> getItemPriceList(
      List<dynamic> filters, String? appBarText, BuildContext context) async {
    var list = [];
    var itemPricelist = <ItemPrice>[];
    var url = '/api/resource/Item Price';
    var customerModel =
        await locator.get<CommonService>().getCustomerDoctypeData();
    var queryParamsCustomerItemPrice = {
      'fields':
          '["name","item_code","item_name","packing_unit","price_list","customer","currency","price_list_rate","uom"]',
      'limit_page_length': '*',
      'filters':
          '[["Item Price","price_list","=","${customerModel.defaultPriceList}"]]'
    };
    try {
      var connectivityStatus =
          Provider.of<ConnectivityStatus>(context, listen: false);
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        var data = locator.get<OfflineStorage>().getItem(Strings.itemPrice);
        // contains cached item price cached data
        if (data['data'] != null) {
          return await locator
              .get<FetchCachedDoctypeService>()
              .fetchCachedItemPriceData();
        }
        // if cached data is not present load data from api
        else {
          // if app bar text is customer item price fetch item price only for customer
          final response = await DioHelper.dio?.get(url,
              queryParameters:
                  // appBarText == Strings.customerItemPrice
                  //     ?
                  queryParamsCustomerItemPrice
              // : queryParams
              ,
              options: Options(
                sendTimeout: const Duration(seconds: Sizes.timeoutDuration),
                receiveTimeout: const Duration(seconds: Sizes.timeoutDuration),
              ));
          if (response?.statusCode == 200) {
            var data = response?.data;
            list = data['data'];
            for (var listJson in list) {
              itemPricelist.add(ItemPrice.fromJson(listJson));
            }
            return itemPricelist;
          }
        }
      } else {
        // offline
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedItemPriceData();
      }
    } catch (e) {
      exception(e, url, 'getItemPriceList');
    }
    return itemPricelist;
  }

  Future<List<ItemPrice>> getItemPrices(
      List<dynamic> filters, ConnectivityStatus connectivityStatus) async {
    var list = [];
    var itemPriceList = <ItemPrice>[];
    var url = '/api/resource/Item Price';
    // var custpricelist = await getPriceList();

    var queryParams = {
      'fields':
          '["name","item_code","item_name","packing_unit","price_list","customer","currency","price_list_rate","uom"]',
      'limit_page_length': '*',
      // 'filters': '[["Item Price","price_list","=","$custpricelist"]]',
    };
    var queryParams1 = {
      'fields': '["name"]',
      'limit_page_length': '*',
    };
    try {
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        final response = await DioHelper.dio?.get(
          url,
          queryParameters: queryParams1,
        );
        if (response?.statusCode == 200) {
          var data = response?.data;
          list = data['data'];
          var ip = <ItemPrice>[];
          for (var listJson in list) {
            ip.add(ItemPrice.fromJson(listJson));
          }

          for (var i = 0; i < ip.length; i++) {
            var ipData = await locator
                .get<ItemsViewModel>()
                .getItemPriceFromName(Strings.itemPrice, ip[i].name ?? '');
            itemPriceList.add(ipData);
          }
          return itemPriceList;
        }
      } else {
        // offline
        await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedItemPriceData();
      }
    } catch (e) {
      exception(e, url, 'getItemPrices');
    }
    return itemPriceList;
  }

  Future<String?> getPriceList() async {
    var customerName = await locator.get<StorageService>().customerSelected;
    var customerModel = CustomerModel();
    var customerData = locator.get<OfflineStorage>().getItem(Strings.customer);
    if (customerData['data'] != null) {
      customerModel = await locator
          .get<CustomerServices>()
          .getCustomerFromCustomerNameFromCache(customerName);
    } else {
      customerModel = await locator
          .get<CustomerServices>()
          .getCustomerFromName(customerName);
    }
    if (customerModel.defaultPriceList?.isNotEmpty == true) {
      return customerModel.defaultPriceList;
    }
    // price list is null fetch default price list from price list doctype
    else {
      //TODO : Fetch from Price List Doctype
      var customerModel =
          await locator.get<CommonService>().getCustomerDoctypeData();
      var pl = customerModel.defaultPriceList;
      return pl;
    }
  }

  Future<List<Product>> getItems(
      List<dynamic> filters, ConnectivityStatus connectivityStatus) async {
    var list = [];
    var itemlist = <Product>[];

    var url = '/api/resource/Item';
    var queryParams = {
      'fields':
          '["name","item_code","item_name","item_group","stock_uom","description","shelf_life_in_days","warranty_period","brand","image"]',
      'limit_page_length': '*',
      'filters': jsonEncode(filters)
    };

    try {
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        final response = await DioHelper.dio?.get(url,
            options: Options(
              sendTimeout: const Duration(seconds: Sizes.timeoutDuration),
              receiveTimeout: const Duration(seconds: Sizes.timeoutDuration),
            ),
            queryParameters: queryParams);
        if (response?.statusCode == 200) {
          var data = response?.data;
          list = data['data'];
          for (var listJson in list) {
            itemlist.add(Product.fromJson(listJson));
          }
          return itemlist;
        }
      } else {
        // offline
        await locator.get<FetchCachedDoctypeService>().fetchCachedItemData();
      }
    } catch (e) {
      exception(e, url, 'getItems');
    }
    return itemlist;
  }

  //for fetching sales order list
  Future<List<SalesOrder>> getSalesOrderList(
      List<dynamic> filters, BuildContext context) async {
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    var list = [];
    var solist = <SalesOrder>[];
    var url = '/api/resource/Sales%20Order';
    var queryParams = {
      'fields': '["*"]',
      'limit_page_length': '*',
      'filters': jsonEncode(filters)
    };
    try {
      connectivityStatus =
          Provider.of<ConnectivityStatus>(context, listen: false);
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        var data = locator.get<OfflineStorage>().getItem(Strings.salesOrder);
        // contains cached sales order display cached data
        if (data['data'] != null) {
          return await locator
              .get<FetchCachedDoctypeService>()
              .fetchCachedSalesOrderData();
        }
        // if cached data is not present load data from api
        else {
          final response = await DioHelper.dio?.get(
            url,
            queryParameters: queryParams,
          );
          if (response?.statusCode == 200) {
            var data = response?.data;
            list = data['data'];
            for (var listJson in list) {
              solist.add(SalesOrder.fromJson(listJson));
            }
            return solist;
          }
        }
      }
      // offline
      else {
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedSalesOrderData();
      }
    } catch (e) {
      exception(e, url, 'getSalesOrderList');
    }
    return solist;
  }

  Future<List<SalesOrder>> getSalesOrders(
      List<dynamic> filters, ConnectivityStatus connectivityStatus) async {
    var list = [];
    var solist = <SalesOrder>[];
    var url = '/api/resource/Sales%20Order';
    var queryParams = {
      'fields': '["*"]',
      'limit_page_length': '*',
      'filters': jsonEncode(filters),
      'order_by': 'modified desc'
    };
    try {
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        final response = await DioHelper.dio?.get(
          url,
          queryParameters: queryParams,
        );
        if (response?.statusCode == 200) {
          var data = response?.data;
          list = data['data'];
          for (var listJson in list) {
            solist.add(SalesOrder.fromJson(listJson));
          }
          return solist;
        }
      }
      // offline
      else {
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedSalesOrderData();
      }
    } catch (e) {
      exception(e, url, 'getSalesOrders');
    }
    return solist;
  }
}
