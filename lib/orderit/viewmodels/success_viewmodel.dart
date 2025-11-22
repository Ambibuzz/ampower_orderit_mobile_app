import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/util/helpers.dart';

class SuccessViewModel extends BaseViewModel {
  var printFormatController = TextEditingController();
  var printFormatList = <String>[];

  void init() {
    printFormatController.clear();
    notifyListeners();
  }

  // share file
  Future<void> shareFile(String? path, String title, String text) async {
    if (path != null) {
      await fileShare(path, title, text);
    }
  }

  Future getPrintFormat() async {
    printFormatList = await locator.get<CommonService>().getDoctypeFieldList(
      '/api/resource/Print Format',
      'name',
      {
        'filters': jsonEncode([
          ["Print Format", "doc_type", "=", "Sales Order"]
        ])
      },
    );
  }

  Future downloadSalesOrder(
      String doctype, String name, BuildContext context) async {
    setState(ViewState.busy);
    if (Platform.isAndroid) {
      if (doctype != null && name != null) {
        var path = await locator
            .get<CommonService>()
            .downloadSalesOrder(doctype!, name!, printFormatController.text);
      } else {
        showSnackBar('Doctype or Doc name is missing', context);
      }
    } else {
      flutterStyledToast(
          context,
          'Download failed or feature not supported for current platform',
          Theme.of(context).colorScheme.surface);
    }
    setState(ViewState.idle);
    notifyListeners();
  }
}
