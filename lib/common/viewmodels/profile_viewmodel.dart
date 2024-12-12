import 'package:orderit/common/models/user.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/colors.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/common/services/logout_api_service.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileViewModel extends BaseViewModel {
  User user = User();
  DateTime dateTime =
      DateFormat('yyyy-MM-dd hh:mm:ss').parse('1960-01-01 12:00:00');
  XFile? file;
  var fullNameController = TextEditingController();
  var mobileNoController = TextEditingController();
  var emailController = TextEditingController();

  String version = '';

  Future logout(BuildContext context) async {
    await locator.get<LogoutService>().logOut(context);
    await DioHelper().signOut();
  }

  void parseDateTime() {
    dateTime = DateFormat('yyyy-MM-dd hh:mm:ss')
        .parse(user.lastLogin ?? '1960-01-01 12:00:00');
  }

  Future getUser() async {
    setState(ViewState.busy);
    var userData = locator.get<OfflineStorage>().getItem('user');
    user = User.fromJson(userData['data']);
    notifyListeners();
    setState(ViewState.idle);
  }

  void initData() async {
    if (user.fullName?.isNotEmpty == true) {
      fullNameController.text = user.fullName ?? '';
    }
    if (user.mobileNo?.isNotEmpty == true) {
      mobileNoController.text = user.mobileNo ?? '';
    }
    if (user.email?.isNotEmpty == true) {
      emailController.text = user.email ?? '';
    }
    var packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    notifyListeners();
  }

  void setImage(XFile? file) {
    this.file = file;
    notifyListeners();
  }

  Future updateUserImage(String imagePath) async {
    final url = '/api/resource/User/${user.email}';
    var data = {
      'user_image': imagePath,
    };
    try {
      final response = await DioHelper.dio?.put(url, data: data);
      if (response?.statusCode == 200) {
        await flutterSimpleToast(Colors.black, const Color(0xFF67DE81),
            'Your changes has been saved successfully!');
      }
    } catch (e) {
      exception(e, url, 'updateUserImage');
    }
  }

  Future updateUser(String? mobileNo) async {
    final url = '/api/resource/User/${user.email}';
    var data = {
      'mobile_no': mobileNo,
    };
    try {
      final response = await DioHelper.dio?.put(url, data: data);
      if (response?.statusCode == 200) {
        await flutterSimpleToast(Colors.black, const Color(0xFF67DE81),
            'Your changes has been saved successfully!');
      }
    } catch (e) {
      exception(e, url, 'updateUserImage');
    }
  }

  Future refetchUpdatedUser() async {
    var user = await locator
        .get<CommonService>()
        .getUser(locator.get<StorageService>().name);
    await locator.get<OfflineStorage>().putItem('user', user.toJson());
    await getUser();
  }
}
