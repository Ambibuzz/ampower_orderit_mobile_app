import 'dart:convert';

import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/quotation_model.dart';
import 'package:orderit/orderit/models/sales_order_model.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/util/apiurls.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:flutter/material.dart';

class CartService {
  // create sales order
  Future<bool> postSalesOrder(
      SalesOrderModel salesOrderModel, BuildContext context) async {
    final url = salesOrderUrl();
    try {
      final response =
          await DioHelper.dio?.post(url, data: jsonEncode(salesOrderModel));
      if (response?.statusCode == 200) {
        var data = response?.data['data'];
        // navigate to success screen
        await locator.get<NavigationService>().navigateTo(
          successViewRoute,
          arguments: [data['doctype'], data['name']],
        );
        return true;
      }
      return false;
    } catch (e) {
      exception(e, url, 'postSalesOrder');
    }
    return false;
  }

  //Function to convert Map<String,dynamic> to Map<String,Cartlist>
  // Map<String, Cartlist> convertMapOfDynamictoMapOfCartlist(
  //     Map<String, dynamic> inputMap) {
  //   var map = <String, Cartlist>{};
  //   // var itemGroupMap = inputMap[key] as Map;
  //   for (var k in inputMap.keys) {
  //     // Map<String, Cartlist> map = {};
  //     Cartlist cartlist = Cartlist.fromJson(inputMap[k]);

  //     // map[k] = ta;
  //     var entry = {k: cartlist};
  //     map.addEntries(entry.entries);
  //   }
  //   return map;
  // }
}
