import 'package:dio/dio.dart';
import 'package:orderit/common/models/user.dart';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/customer_model.dart';
import 'package:orderit/orderit/services/customer_service.dart';
import 'package:orderit/orderit/services/user_service.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/apiurls.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/util/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';

//LoginApiService class contains function login
class LoginService {
  //For doing login based on the username and password
  Future login(
      {required String username,
      required String password,
      required String baseUrl,
      required BuildContext context}) async {
    final url = loginUrl();

    try {
      await DioHelper.init(baseUrl);
      final response = await DioHelper.dio?.post(
        url,
        data: {'usr': username, 'pwd': password},
        options: Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      if (response?.statusCode == 200) {
        var storageService = locator.get<StorageService>();
        var data = response?.data;
        String fullname = data['full_name'];
        var loggedInUserName = await locator.get<CommonService>().getUsername();
        var user = await locator
            .get<CommonService>()
            .getUserFromEmail(loggedInUserName);
        await checkIfLoginUserHasChanged(user);
        storageService.apiUrl = baseUrl;
        await DioHelper.init(baseUrl);
        await DioHelper.initCookies();
        storageService.userName = username;
        storageService.loggedIn = true;
        storageService.name = fullname;
        await storageService.setBool(PreferenceVariables.loggedIn, true);
        await locator.get<OfflineStorage>().putItem('user', user.toJson());
        // cache orderit config
        var doctypeCachingService = locator.get<DoctypeCachingService>();

        var isUserCustomer =
            await locator.get<UserService>().checkIfUserIsCustomer();
        storageService.isUserCustomer = isUserCustomer;

        // if user is customer set pricelist to customerpricelist
        if (isUserCustomer) {
          // get Customer and set pricelist
          if (user.email != null) {
            var customerModel = await getCustomerData(user.email!);
            if (customerModel.customerName != null) {
              storageService.customer = customerModel.customerName!;
              storageService.customerSelected = customerModel.customerName!;
            }
            if (customerModel.defaultPriceList != null) {
              storageService.priceList = customerModel.defaultPriceList!;
            } else {}
          }
        }
        // if not a customer set to default pricelist
        else {}
        var userId =
            response?.headers.map['set-cookie']?[3].split(';')[0].split('=')[1];

        var itemGroupData =
            locator.get<OfflineStorage>().getItem(Strings.itemGroupTree);
        if (itemGroupData['data'] == null) {
          await doctypeCachingService.cacheItemGroups(
              Strings.itemGroupTree, ConnectivityStatus.wifi);
        }

        var cookie = response!.headers.map['set-cookie'];
        var cookieString = cookie!.first.toString();
        var cookieSid = cookieString.split(';')[0];
        storageService.cookie = cookieSid;
        // cache customer list
        await locator.get<DoctypeCachingService>().cacheCustomerNameList(
            Strings.customerNameList, ConnectivityStatus.wifi);
        if (isUserCustomer) {
          await locator
              .get<NavigationService>()
              .pushReplacementNamed(itemCategoryNavBarRoute);
        } else {
          await locator
              .get<NavigationService>()
              .pushReplacementNamed(enterCustomerRoute);
        }
      } else {
        await showErrorToast(response);
      }
    } catch (e) {
      exception(e, url, 'login');
    }
  }

  Future checkIfLoginUserHasChanged(User currentUser) async {
    var previousDetails = locator.get<UserService>().getUser();
    if (previousDetails.fullName != null ||
        previousDetails.fullName?.isNotEmpty == true) {
      // if current and previous credentials dont match means login has changes
      if (currentUser.fullName != previousDetails.fullName) {
        locator.get<StorageService>().isLoginChanged = true;
      }
    }
  }

  Future<CustomerModel> getCustomerData(String email) async {
    var customerData = locator.get<OfflineStorage>().getItem(Strings.customer);
    CustomerModel customerModel;
    if (customerData['data'] != null) {
      customerModel = await locator
          .get<CustomerServices>()
          .getCustomerFromEmailFromCache(email);
    } else {
      customerModel =
          await locator.get<CustomerServices>().getCustomerFromEmailId(email);
    }
    return customerModel;
  }
}
