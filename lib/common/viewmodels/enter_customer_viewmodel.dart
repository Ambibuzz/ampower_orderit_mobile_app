import 'package:orderit/common/models/global_defaults.dart';
import 'package:orderit/common/models/user.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/common/models/accounts_recievable_model.dart';
import 'package:orderit/common/models/customer_doctype_model.dart';
import 'package:orderit/common/services/report_service.dart';
import 'package:orderit/orderit/services/orderit_api_service.dart';
import 'package:orderit/orderit/services/user_service.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnterCustomerViewModel extends BaseViewModel {
  List<String> customer = [];
  var globalDefaults = GlobalDefaults();
  var accountsRecievable = AccountsRecievable();
  var customerDoctype = CustomerDoctype();
  dynamic response;
  var customerFocusNode = FocusNode();
  final TextEditingController customerController = TextEditingController();
  User user = User();

  Future<int> checkSessionExpired() async {
    setState(ViewState.busy);
    var statusCode = await locator.get<CommonService>().checkSessionExpired();
    setState(ViewState.idle);
    return statusCode;
  }

  void getUser() {
    user = locator.get<UserService>().getUser();
    notifyListeners();
  }

  void init() {
    accountsRecievable = AccountsRecievable();
    customerDoctype = CustomerDoctype();
    customerController.clear();
    notifyListeners();
  }

  void unfocus(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (customerController.text.isEmpty == true) {
      customerDoctype = CustomerDoctype();
      accountsRecievable = AccountsRecievable();
    }
    customerFocusNode.unfocus();
    notifyListeners();
  }

  Future getGlobalDefaults() async {
    globalDefaults = await locator.get<CommonService>().getGlobalDefaults();
    notifyListeners();
  }

  Future getAccountsRecievableReport(String? customer, String? company) async {
    accountsRecievable = await locator
        .get<ReportService>()
        .getAccountsRecievableReport(customer, company);
    response = await locator
        .get<ReportService>()
        .getAccountsRecievableReportResponse(customer, company);
    print(response);
    notifyListeners();
  }

  Future getCustomerDoctype(String? customer) async {
    customerDoctype =
        await locator.get<OrderitApiService>().getCustomerDoctype(customer);
    notifyListeners();
  }

  // get customer list
  Future getCustomer(String? fromRoute, BuildContext context) async {
    setState(ViewState.busy);
    var doctypeCachingService = locator.get<DoctypeCachingService>();
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    var data = locator.get<OfflineStorage>().getItem(Strings.customerNameList);
    if (data['data'] == null) {
      await doctypeCachingService.cacheCustomerNameList(
          Strings.customerNameList, connectivityStatus);
    }
    customer = await locator
        .get<FetchCachedDoctypeService>()
        .getCachedCustomerList(connectivityStatus);
    notifyListeners();
    setState(ViewState.idle);
  }
}
