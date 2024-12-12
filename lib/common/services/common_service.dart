import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:orderit/common/models/currency_model.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/customer_model.dart';
import 'package:orderit/orderit/models/price_list.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/common/models/user.dart';
import 'package:orderit/common/models/global_defaults.dart';
import 'package:orderit/orderit/models/quotation.dart';
import 'package:orderit/orderit/services/customer_service.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:orderit/common/models/item_group.dart';
import 'package:orderit/common/models/items_model.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/util/apiurls.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonService {
  //for fetching username
  Future<int> checkSessionExpired() async {
    final url = usernameUrl();
    try {
      final response = await DioHelper.dio?.get(url);
      return response?.statusCode ?? 400;
    } catch (e) {
      exception(e, url, 'checkSessionExpired');
    }
    return 0;
  }

  //for fetching currency list
  Future<List<CurrencyModel>> getCurrencyList(
      List<dynamic> filters, ConnectivityStatus connectivityStatus) async {
    var list = [];
    var clist = <CurrencyModel>[];
    var url = '/api/resource/Currency';
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
            clist.add(CurrencyModel.fromJson(listJson));
          }
          return clist;
        }
      }
      // offline
      else {
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedCurrencyData();
      }
    } catch (e) {
      exception(e, url, 'getCurrencyList');
    }
    return clist;
  }

  Future<CustomerModel> getCustomerDoctypeData() async {
    var customerData = locator.get<OfflineStorage>().getItem(Strings.customer);
    var customerName = locator.get<StorageService>().customerSelected;
    if (customerData['data'] != null) {
      return await locator
          .get<CustomerServices>()
          .getCustomerFromCustomerNameFromCache(customerName);
    } else {
      return await locator
          .get<CustomerServices>()
          .getCustomerFromName(customerName);
    }
  }

  // get single field data from doctype ie getting item_name list from item doctype
  Future<List<String>> getDoctypeFieldList(
      String url, String field, Map<String, String> queryParams) async {
    var docFieldList = <String>[];
    try {
      queryParams['limit_page_length'] = '*';

      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );
      if (response?.statusCode == 200) {
        var data = response?.data;
        var list = data['data'];
        for (var listJson in list) {
          docFieldList.add(listJson[field]);
        }
        return docFieldList;
      }
    } catch (e) {
      exception(e, url, 'getDoctypeFieldList', showToast: false);
      return [];
    }
    return docFieldList;
  }

  //For fetching itemcode from itemname
  Future<String> getItemCodeFromItemName(String text) async {
    var itemCode = '';
    const url = '/api/resource/Item';
    var queryParams = {
      'fields': '["*"]',
      'filters': '[["Item", "item_name", "like", "$text"]]'
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );
      if (response?.statusCode == 200) {
        var data = response?.data;
        itemCode = data['data'][0]['name'] as String;
        return itemCode;
      }
    } catch (e) {
      exception(e, url, 'getItemCodeFromItemName');
    }
    return itemCode;
  }

  Future<List<String>> getItemGroupList() async {
    var itemGroupList = <ItemGroupModel>[];
    var itemGroupName = <String>[];
    var url = '/api/resource/Item%20Group';
    var queryParams = {
      'fields': '["*"]',
      'limit_page_length': '*',
    };

    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200) {
        var data = response?.data;
        List listData = data['data'];
        for (var itemGroup in listData) {
          itemGroupList.add(ItemGroupModel.fromJson(itemGroup));
        }
        for (var item in itemGroupList) {
          itemGroupName.add(item.name!);
        }
        return itemGroupName;
      }
    } catch (e) {
      exception(e, url, 'getItemGroupList');
    }
    return itemGroupName;
  }

  //For fetching list of items (itemname,itemcode) data from item api
  Future<List> getItemList() async {
    var listData = [];
    const url = '/api/resource/Item';
    var queryParams = {
      'fields': '["item_code", "item_name"]',
      'limit_page_length': '*'
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200) {
        var data = response?.data;
        listData = data['data'];
      }
    } catch (e) {
      exception(e, url, 'getItemList');
    }
    return listData;
  }

  Future<List<String>> getItemNameList() async {
    var itemsList = <ItemsModel>[];
    var itemNameList = <String>[];
    const url = '/api/resource/Item';
    var queryParams = {
      'fields': '["item_code","item_name"]',
      'limit_page_length': '*'
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200) {
        var data = response?.data;
        List listData = data['data'];
        for (var itemData in listData) {
          itemsList.add(ItemsModel.fromJson(itemData));
        }
        for (var item in itemsList) {
          itemNameList.add(item.itemName);
        }
        return itemNameList;
      }
    } catch (e) {
      exception(e, url, 'getItemNameList');
    }
    return itemNameList;
  }

  Future<List<ItemsModel>> getItemsList() async {
    var itemsList = <ItemsModel>[];
    const url = '/api/resource/Item';
    var queryParams = {
      'fields': '["item_code","item_name"]',
      'limit_page_length': '*'
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200) {
        var data = response?.data;
        List listData = data['data'];
        for (var itemData in listData) {
          itemsList.add(ItemsModel.fromJson(itemData));
        }
        return itemsList;
      }
    } catch (e) {
      exception(e, url, 'getItemsList');
    }
    return itemsList;
  }

  Future<String?> getPhoneNoFromAddress(String? address) async {
    String? phoneNo;
    var url = '/api/resource/Address/$address';

    try {
      final response = await DioHelper.dio?.get(
        url,
      );

      if (response?.statusCode == 200) {
        var data = response?.data;

        phoneNo = data['data']['phone'];
        return phoneNo;
      }
    } catch (e) {
      exception(e, url, 'getPhoneNoFromAddress');
    }
    return '';
  }

  Future<String> pdfFromDocName(String doctype, String docname) async {
    var storagePermission = await [
      Permission.storage,
    ].request();
    try {
      String fullPath;
      if (storagePermission.isNotEmpty) {
        var downloadsDirectoryPath = '/storage/emulated/0/Download';
        var downpath = '$downloadsDirectoryPath/${Strings.ampower}';
        var url = '/api/method/frappe.utils.print_format.download_pdf';
        var queryParams = {
          'doctype': doctype,
          'name': docname,
        };
        var fileName =
            '/$docname${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}.pdf';
        fullPath = downpath + fileName;
        await DioHelper.dio?.download(
          url,
          fullPath,
          queryParameters: queryParams,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              }),
        );
        return fullPath;
      }
    } catch (e) {
      exception(e, '', 'pdfFromDocName');
    }
    return '';
  }

  Future<PriceList> getPriceList(String p) async {
    final url = pricelistUrl(p);

    try {
      final response = await DioHelper.dio?.get(url);
      if (response?.statusCode == 200) {
        return PriceList.fromJson(response?.data['data']);
      }
    } catch (e) {
      exception(e, url, 'getPriceList');
    }
    return PriceList();
  }

  //For fetching data from item api in product model
  Future<Product> getProductFromItemCode(String text) async {
    final url = itemDataUrl(text);

    try {
      final response = await DioHelper.dio?.get(url);
      if (response?.statusCode == 200) {
        return Product.fromJson(response?.data['data']);
      }
    } catch (e) {
      exception(e, url, 'getProductFromItemCode');
    }
    return Product();
  }

  //For fetching data for specific itemname from item api
  Future<Product> getProductFromItemName(String text) async {
    var url = '/api/resource/Item';
    var queryParams = {
      'fields': '["*"]',
      'filters': '[["Item","item_name","like","$text"]]'
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );
      if (response?.statusCode == 200) {
        return Product.fromJson(response?.data['data'][0]);
      }
    } catch (e) {
      exception(e, url, 'getProductFromItemName');
    }
    return Product();
  }

  //for fetching username
  Future<String> getUsername() async {
    var username = '';
    final url = usernameUrl();

    try {
      final response = await DioHelper.dio?.get(url);

      if (response?.statusCode == 200) {
        var data = response?.data;
        username = data['message'];
        return username;
      }
    } catch (e) {
      exception(e, url, 'getUsername');
    }
    return username;
  }

  Future<SalesOrder> getSalesOrder(String doctype, String name) async {
    final cu = doctypeDetailUrl(doctype, name);
    try {
      final response = await DioHelper.dio?.get(cu);
      if (response?.statusCode == 200) {
        var data = response?.data;
        var so = SalesOrder.fromJson(data['data']);
        return so;
      }
    } catch (e) {
      exception(e, cu, 'getSalesOrder');
    }
    return SalesOrder();
  }

  Future<Quotation> getQuotation(String doctype, String name) async {
    final qurl = doctypeDetailUrl(doctype, name);
    try {
      final response = await DioHelper.dio?.get(qurl);
      if (response?.statusCode == 200) {
        var data = response?.data;
        var quotation = Quotation.fromJson(data['data']);
        return quotation;
      }
    } catch (e) {
      exception(e, qurl, 'getQuotation');
    }
    return Quotation();
  }

  Future<User> getUser(String fullname) async {
    User user;
    var url = '/api/resource/User';
    var queryParams = {
      'fields': '["*"]',
      'filters': '[["User","full_name","=","$fullname"]]',
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200) {
        user = User.fromJson(response?.data['data'][0]);
        return user;
      }
    } catch (e) {
      exception(e, url, 'getUser');
    }
    return User();
  }

  Future<User> getUserFromEmail(String email) async {
    User user;
    var url = '/api/resource/User';
    var queryParams = {
      'fields': '["*"]',
      'filters': '[["User","email","=","$email"]]',
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );

      if (response?.statusCode == 200) {
        user = User.fromJson(response?.data['data'][0]);
        return user;
      }
    } catch (e) {
      exception(e, url, 'getUser');
    }
    return User();
  }

  Future<GlobalDefaults> getGlobalDefaults() async {
    var globalDefaults = GlobalDefaults();
    final gdurl = globalDefaultsUrl();

    try {
      final response = await DioHelper.dio?.get(gdurl);
      if (response?.statusCode == 200) {
        var data = response?.data;
        globalDefaults = GlobalDefaults.fromJson(data['data']);
        return globalDefaults;
      }
    } catch (e) {
      exception(e, gdurl, 'getGlobalDefaults');
    }
    return GlobalDefaults();
  }

  // open sms app,text message,call app
  Future send(BuildContext context, String url, String? mobileNo) async {
    if (mobileNo != null) {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        showSnackBar('Could not launch $url', context);
      }
    } else {
      showSnackBar('Mobile no field is empty', context);
    }
  }

  Future<double> getMax(List<double> list) async {
    var max = list[0];
    for (var d in list) {
      if (d > max) {
        max = d;
      }
    }
    return max;
  }
}
