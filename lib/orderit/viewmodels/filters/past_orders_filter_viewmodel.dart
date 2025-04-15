import 'package:flutter/material.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/util/constants/lists.dart';

class PastOrdersFilterViewModel extends BaseViewModel {
  String? statusTextSO = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  var startDateController = TextEditingController();
  var endDateController = TextEditingController();

  void clearData() {
    startDateController.clear();
    endDateController.clear();
    setStatusSO(Lists.salesOrderStatus[0]);
    notifyListeners();
  }

  void setStatusSO(String? status) {
    statusTextSO = status ?? '';
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    if (date != null) startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    if (date != null) endDate = date;
    notifyListeners();
  }
}
