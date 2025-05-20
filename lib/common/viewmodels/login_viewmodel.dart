import 'package:dio/dio.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/common/services/login_api_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:orderit/util/helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginViewModel extends BaseViewModel {
  var version = '';

  Future<void> init() async {
    await initDb();
    var packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    notifyListeners();
  }

  Future<String> getUsername() async {
    var username = locator.get<StorageService>().userName;
    return username;
  }

  Future login(String baseurl, String username, String password,
      BuildContext context) async {
    setState(ViewState.busy);
    notifyListeners();
    await locator.get<LoginService>().login(
          baseUrl: baseurl,
          password: password,
          username: username,
          context: context,
        );
    setState(ViewState.idle);
    notifyListeners();
  }

  Future<String> getInstanceUrl() async {
    var instanceUrl = locator.get<StorageService>().apiUrl;
    return instanceUrl;
  }

  Future<bool> isUrlActive(String url) async {
    final dio = Dio();
    try {
      // Use a HEAD request for efficiency
      final response = await dio.head(url);

      // Check if the status code is in the 2xx range (success)
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException catch (e) {
      // Handle specific errors like timeouts, 404, etc.
      if (e.response != null) {
        return false; // URL exists but is not active
      } else {
        return false; // URL doesn't exist or can't be reached
      }
    } catch (e) {
      return false;
    }
  }
}
