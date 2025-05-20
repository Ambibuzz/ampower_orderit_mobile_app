
import 'dart:convert';

import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/common/models/error_log.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/locators/locator.dart';

class ErrorLogListViewModel extends BaseViewModel {
  var errorLogList = <ErrorLog>[];
  bool isErrorLogLoading = false;

  Future getErrorLogList() async {
    isErrorLogLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    errorLogList = await getErrorLogListFromCache();
    // sort error logs by recent
    errorLogList.sort((a, b) => b.id!.compareTo(a.id!));
    isErrorLogLoading = false;
    notifyListeners();
  }

  Future<List<ErrorLog>> getErrorLogListFromCache() async {
    var errorLog = <ErrorLog>[];
    try {
      var data = locator.get<OfflineStorage>().getItem('errorlog');

      if (data['data'] != null) {
        var el = ErrorLogList.fromJson(jsonDecode(data['data']));
        if (el.errorLogList?.isNotEmpty == true) {
          errorLog = el.errorLogList!;
          return errorLog;
        } else {
          return errorLog;
        }
      } else {
        return [];
      }
    } catch (e) {
      exception(e, '', 'getErrorLogListFromCache');
      return [];
    }
  }
}