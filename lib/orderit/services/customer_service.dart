import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/customer_model.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/base_viewmodel.dart';

class CustomerServices extends BaseViewModel {
  Future<CustomerModel> getCustomerFromEmailId(String? email) async {
    try {
      if (email != null) {
        final response = await DioHelper.dio?.get(
          '/api/resource/Customer',
          queryParameters: {
            'fields': '["*"]',
            'filters': '[["Customer","email_id","=","$email"]]',
            'limit_page_length': '*'
          },
        );
        var data = response?.data['data'];
        if (data is List) {
          var customerModel = CustomerModel.fromJson(data[0]);
          return customerModel;
        }
        var customerModel = CustomerModel.fromJson(data);
        return customerModel;
      }
    } catch (e) {
      exception(e, '/api/resource/Customer', 'getCustomerFromEmailId');
    }

    return CustomerModel();
  }

  Future<CustomerModel> getCustomerFromEmailIdFromCache(String? email) async {
    var customer = CustomerModel();
    var customers = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedCustomerData();
    if (customers.isNotEmpty) {
      customer = customers.firstWhere((customer) => customer.emailId == email,
          orElse: () => customer);
      return customer;
    }
    return customer;
  }

  Future<CustomerModel> getCustomerFromName(String? name) async {
    try {
      if (name != null) {
        final customerIdResponse = await DioHelper.dio?.get(
          '/api/resource/Customer',
          queryParameters: {
            'fields': '["name","default_price_list"]',
            'filters': '[["Customer","customer_name","=","$name"]]',
            'limit_page_length': '*'
          },
        );
        var data = customerIdResponse?.data['data'];
        if (data is List) {
          var customerId = data[0]['name'];
          final response =
              await DioHelper.dio?.get('/api/resource/Customer/$customerId');

          if (response?.statusCode == 200) {
            var customerModel = CustomerModel.fromJson(response?.data['data']);
            return customerModel;
          } else {
            await showErrorToast(response);
          }
        }
        var customerModel = CustomerModel.fromJson(data);
        return customerModel;
      }
    } catch (e) {
      exception(e, '/api/resource/Customer', 'getCustomerFromName');
    }

    return CustomerModel();
  }

  Future<CustomerModel> getCustomerFromCustomerNameFromCache(
      String? customerName) async {
    var customer = CustomerModel();
    var customers = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedCustomerData();
    if (customers.isNotEmpty) {
      customer = customers.firstWhere(
          (customer) => customer.customerName == customerName,
          orElse: () => customer);
      return customer;
    }
    return customer;
  }

  Future<CustomerModel> getCustomerFromEmailFromCache(String? email) async {
    var customer = CustomerModel();
    var customers = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedCustomerData();
    if (customers.isNotEmpty) {
      customer = customers.firstWhere((customer) => customer.emailId == email,
          orElse: () => customer);
      return customer;
    }
    return customer;
  }
}
