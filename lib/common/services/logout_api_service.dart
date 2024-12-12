import 'package:orderit/config/exception.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/util/apiurls.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/preference.dart';
import 'package:flutter/material.dart';

//LogoutApiService class contains function for fetching data or posting  data
class LogoutService {
  Future logOut(BuildContext context) async {
    try {
      final response = await DioHelper.dio?.post(logoutUrl());
      if (response?.statusCode == 200) {
        var storageService = locator.get<StorageService>();
        storageService.loggedIn = false;
        storageService.removeCookie = PreferenceVariables.cookie;
        storageService.removeName = PreferenceVariables.name;
        storageService.removeCompany = PreferenceVariables.company;
        storageService.removeUserName = PreferenceVariables.userName;
        storageService.isUserCustomer = false;
        locator.get<StorageService>().isLoginChanged = true;
        await locator
            .get<NavigationService>()
            .pushNamedAndRemoveUntil(loginViewRoute, (_) => false);
      }
    } catch (e) {
      exception(e, logoutUrl(), 'logOut');
    }
  }
}
