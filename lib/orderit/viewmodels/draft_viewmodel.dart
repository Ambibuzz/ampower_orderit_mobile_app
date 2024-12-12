import 'dart:convert';

import 'package:orderit/common/services/dialog_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/common/widgets/custom_alert_dialog.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/draft.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DraftViewModel extends BaseViewModel {
  List<Draft>? drafts = [];

  void refresh() {
    notifyListeners();
  }

  Future getDrafts() async {
    List<Draft>? draftsListFiltered = [];
    var data = locator.get<OfflineStorage>().getItem('draft');
    if (data['data'] != null) {
      var dl = Draftlist.fromJson(jsonDecode(data['data']));
      if (dl.draftList?.isNotEmpty == true) {
        drafts = dl.draftList!
            .where((e) =>
                e.customer == locator.get<StorageService>().customerSelected)
            .toList();
      }
      drafts?.forEach((d) {
        // var dt1 = DateFormat('yyyy-MM-dd hh:mm:ss').parse(d.time!);
        var dt1 = DateTime.now();
        var dt2 = DateFormat('yyyy-MM-dd hh:mm:ss').parse(d.expiry!);
        // var text = '';
        var diff = dt2.difference(dt1);
        // int daysLeft = diff.inDays.abs();
        var daysLeft = diff.inDays;
        // Max 5 days are allowed
        if (!daysLeft.isNegative) {
          draftsListFiltered.add(d);
        }
      });
      drafts = draftsListFiltered;
      // sort draft in descending order
      drafts?.sort((a, b) => b.time!.compareTo(a.time!));
    }

    // setState(ViewState.idle);
    notifyListeners();
  }

  Future showDialog(int index, BuildContext context) async {
    await CustomAlertDialog().alertDialog(
      'Remove Draft Order',
      'Are you sure you want to remove this draft?',
      'Cancel',
      'Ok',
      () {
        Navigator.of(context, rootNavigator: true).pop();
      },
      () {
        remove(index);
        Navigator.of(context, rootNavigator: true).pop();
      },
      context,
    );
  }

  void remove(int index) {
    drafts?.removeAt(index);
    //save to hive
    notifyListeners();
    updateDraft();
  }

  void removeAll() {
    drafts?.clear();
    //save to hive
    notifyListeners();
    updateDraft();
  }

  void updateDraft() {
    var customerName = locator.get<StorageService>().customerSelected;
    if (customerName.isNotEmpty) {
      var draft = Draftlist(draftList: drafts);
      //update draftMap with current list
      locator
          .get<OfflineStorage>()
          .putItem('draft', jsonEncode(draft.toJson()));
    }

    notifyListeners();
  }
}
