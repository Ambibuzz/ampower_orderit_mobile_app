import 'package:orderit/locators/locator.dart';
import 'package:orderit/common/services/login_api_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends BaseViewModel {
  Future<String> getUsername() async {
    var username = locator.get<StorageService>().userName;
    return username;
  }

  Future login(String baseurl, String username, String password,
      BuildContext context) async {
    setState(ViewState.busy);
    await locator.get<LoginService>().login(
          baseUrl: baseurl,
          password: password,
          username: username,
          context: context,
        );
    setState(ViewState.idle);
  }

  Future<String> getInstanceUrl() async {
    var instanceUrl = locator.get<StorageService>().apiUrl;
    return instanceUrl;
  }
}
