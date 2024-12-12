import 'package:orderit/base_viewmodel.dart';

class PastOrdersFilterViewModel extends BaseViewModel {
  String? statusTextSO = '';

  void setStatusSO(String? status) {
    statusTextSO = status ?? '';
    notifyListeners();
  }
}
