import 'dart:convert';

import 'package:orderit/common/models/error_log.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/locators/locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ErrorLogService {
  Future<void> saveErrorLog(
      String error, int? statusCode, dynamic errorResponse) async {
    var dateTimeObj = DateTime.now();
    var exception = errorResponse.response!.data['exception'] ?? '';

    var packageInfo = await PackageInfo.fromPlatform();

    var errorLog = ErrorLog(
        id: dateTimeObj.millisecondsSinceEpoch,
        time: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeObj),
        error: error,
        version: packageInfo.version,
        exception: exception ?? '',
        statusCode: statusCode ?? 0);

    //get errorlogMap
    var data = locator.get<OfflineStorage>().getItem('errorlog');
    // print(data);

    // print(data);
    // data is not null means errorlog are there
    // fetch old errorlogs and add errorlog to errorloglist
    if (data['data'] != null) {
      // print(errorlogMap[customerName]);
      // fetch old errorlogs
      var errorLogs = ErrorLogList.fromJson(jsonDecode(data['data']));
      print(errorLogs.errorLogList?.length);
      errorLogs.errorLogList?.forEach((d) {
        print(d.time);
      });
      // print(errorloglist.toJson());

      //store errorlog to old errorlogs
      var errorLogList = errorLogs.errorLogList;
      errorLogList?.add(errorLog);
      print(errorLogList?.length);

      errorLogs = ErrorLogList(errorLogList: errorLogList);

      // print(errorlogMap);
      //update errorlogMap with current list
      await locator
          .get<OfflineStorage>()
          .putItem('errorlog', jsonEncode(errorLogs.toJson()));
    }
    // errorlog is empty insert errorlog and save it to hive db
    else {
      var errorLogList = ErrorLogList(errorLogList: [errorLog]);

      // print(map);
      await locator
          .get<OfflineStorage>()
          .putItem('errorlog', jsonEncode(errorLogList.toJson()));
    }
  }
}
