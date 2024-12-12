import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/user_model.dart';
import 'package:orderit/common/models/user.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/util/apiurls.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/base_viewmodel.dart';

class UserService extends BaseViewModel {
  // get user
  Future<UserModel> getUserData() async {
    var userData = locator.get<OfflineStorage>().getItem('user');
    var user = User.fromJson(userData['data']);
    try {
      // if user name is null in offline storage then try to fetch from storage service usern name
      if (user.name == null) {
        var user = await locator
            .get<CommonService>()
            .getUser(locator.get<StorageService>().name);
        await locator.get<OfflineStorage>().putItem('user', user.toJson());
        var userData = locator.get<OfflineStorage>().getItem('user');
        user = User.fromJson(userData['data']);
        final url = userUrl(user.email ?? '');
        final response = await DioHelper.dio?.get(url);
        var userModel = UserModel.fromJson(response?.data['data']);
        return userModel;
      }
      // if user name is not null search from user email
      final url = userUrl(user.email ?? '');
      final response = await DioHelper.dio?.get(url);

      if (response?.statusCode == 200) {
        var userModel = UserModel.fromJson(response?.data['data']);
        return userModel;
      }
    } catch (e) {
      exception(e, '/api/resource/User', 'getUserData');
    }

    return UserModel();
  }

  User getUser() {
    var userData = locator.get<OfflineStorage>().getItem('user');
    if (userData['data'] == null) {
      return User();
    } else {
      var user = User.fromJson(userData['data']);
      return user;
    }
  }

  Future<bool> checkIfCustomerExistsForUser(String? emailId) async {
    try {
      // if user name is null in offline storage then try to fetch from storage service usern name
      final response = await DioHelper.dio?.get(
        '/api/resource/Customer',
        queryParameters: {
          'fields': '["name"]',
          'filters': '[["Customer","email_id","=","$emailId"]]',
          'limit_page_length': '*'
        },
      );
      if (response?.statusCode == 200) {
        var customerList = response?.data['data'] as List;
        if (customerList.isEmpty) {
          return false;
        } else {
          return true;
        }
      }
    } catch (e) {
      exception(e, '/api/resource/User', 'getUserData');
    }

    return false;
  }

  Future<bool> checkIfUserIsCustomer() async {
    var isUserCustomer = false;
    var storedUser = locator.get<OfflineStorage>().getItem('user');
    var userData = User.fromJson(storedUser['data']);
    final url = userUrl(userData.email ?? '');
    final response = await DioHelper.dio?.get(url);
    var user = UserModel.fromJson(response?.data['data']);
    user = await locator.get<UserService>().getUserData();
    // get customer with reference to user
    if (user.email != null) {
      // if customer data is not empty set isUserCustomer to true
      var userExists = await checkIfCustomerExistsForUser(userData.email);
      if (userExists) {
        return true;
      }
      // else set isUserCustomer to false
      else {
        return false;
      }
    }
    return isUserCustomer;
  }
}
