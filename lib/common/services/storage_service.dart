import 'package:orderit/config/logger.dart';
import 'package:orderit/util/preference.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  final log = getLogger('Storage Service');

  Box getHiveBox(String name) {
    return Hive.box(name);
  }

  Future<Box> initHiveBox(String name) {
    return Hive.openBox(name);
  }

  Future initHiveStorage() {
    return Hive.initFlutter();
  }

  static Future<StorageService?> getInstance() async {
    _instance ??= StorageService();
    _preferences ??= await SharedPreferences.getInstance();

    return _instance;
  }

  dynamic _getFromDisk(String key) {
    var value = _preferences?.get(key);
    // print('(TRACE) LocalStorageService:_getFromDisk. key: $key value: $value');
    // log.i('(TRACE) LocalStorageService:_getFromDisk. key: $key value: $value');
    return value;
  }

  void _saveToDisk<T>(String key, T content) {
    // print('(TRACE) LocalStorageService:_saveToDisk. key: $key value: $content');
    // log.i('(TRACE) LocalStorageService:_saveToDisk. key: $key value: $content');
    if (content is String) {
      _preferences?.setString(key, content);
    }
    if (content is bool) {
      _preferences?.setBool(key, content);
    }
    if (content is int) {
      _preferences?.setInt(key, content);
    }
    if (content is double) {
      _preferences?.setDouble(key, content);
    }
    if (content is List<String>) {
      _preferences?.setStringList(key, content);
    }
  }

  void _remove(String key) {
    // print('(TRACE) LocalStorageService:_remove. key: $key ');
    getLogger('(TRACE) LocalStorageService:_remove. key: $key ');
  }

  String get accessToken => _getFromDisk(PreferenceVariables.accessToken) ?? '';
  set accessToken(String value) =>
      _saveToDisk(PreferenceVariables.accessToken, value);
  set removeAccessToken(String key) => _remove(key);

  String get refreshToken =>
      _getFromDisk(PreferenceVariables.refreshToken) ?? '';
  set refreshToken(String value) =>
      _saveToDisk(PreferenceVariables.refreshToken, value);
  set removeRefreshToken(String key) => _remove(key);

  String get code => _getFromDisk(PreferenceVariables.code) ?? '';
  set code(String value) => _saveToDisk(PreferenceVariables.code, value);
  set removeCode(String key) => _remove(key);

  bool get login => _getFromDisk(PreferenceVariables.loggedIn) ?? false;
  set login(bool value) => _saveToDisk(PreferenceVariables.loggedIn, value);
  set removeLogin(String key) => _remove(key);

  String get apiUrl => _getFromDisk(PreferenceVariables.apiUrl) ?? '';
  set apiUrl(String value) => _saveToDisk(PreferenceVariables.apiUrl, value);
  set removeApiUrl(String key) => _remove(key);

  String get company => _getFromDisk(PreferenceVariables.company) ?? '';
  set company(String value) => _saveToDisk(PreferenceVariables.company, value);
  set removeCompany(String key) => _remove(key);

  String get customer => _getFromDisk(PreferenceVariables.customer) ?? '';
  set customer(String value) =>
      _saveToDisk(PreferenceVariables.customer, value);
  set removeCustomer(String key) => _remove(key);

  String get customerSelected =>
      _getFromDisk(PreferenceVariables.customerSelected) ?? '';
  set customerSelected(String value) =>
      _saveToDisk(PreferenceVariables.customerSelected, value);
  set removeCustomerSelected(String key) => _remove(key);

  String get cookie => _getFromDisk(PreferenceVariables.cookie) ?? '';
  set cookie(String value) => _saveToDisk(PreferenceVariables.cookie, value);
  set removeCookie(String key) => _remove(key);

  bool get loggedIn => _getFromDisk(PreferenceVariables.loggedIn) ?? false;
  set loggedIn(bool value) => _saveToDisk(PreferenceVariables.loggedIn, value);
  set removeLoggedIn(String key) => _remove(key);

  bool get isUserCustomer =>
      _getFromDisk(PreferenceVariables.isUserCustomer) ?? false;
  set isUserCustomer(bool value) =>
      _saveToDisk(PreferenceVariables.isUserCustomer, value);
  set removeIsUserCustomer(String key) => _remove(key);

  bool get isLoginChanged =>
      _getFromDisk(PreferenceVariables.isLoginChanged) ?? false;
  set isLoginChanged(bool value) =>
      _saveToDisk(PreferenceVariables.isLoginChanged, value);
  set removeisLoginChanged(String key) => _remove(key);

  String get name => _getFromDisk(PreferenceVariables.name) ?? '';
  set name(String value) => _saveToDisk(PreferenceVariables.name, value);
  set removeName(String key) => _remove(key);

  String get priceList => _getFromDisk(PreferenceVariables.priceList) ?? '';
  set priceList(String value) =>
      _saveToDisk(PreferenceVariables.priceList, value);
  set removePriceList(String key) => _remove(key);

  String get userName => _getFromDisk(PreferenceVariables.userName) ?? '';
  set userName(String value) =>
      _saveToDisk(PreferenceVariables.userName, value);
  set removeUserName(String key) => _remove(key);

  String get salesPerson => _getFromDisk(PreferenceVariables.salesPerson) ?? '';
  set salesPerson(String value) =>
      _saveToDisk(PreferenceVariables.salesPerson, value);
  set removeSalesPerson(String key) => _remove(key);

  bool get theme => _getFromDisk(PreferenceVariables.theme) ?? false;
  set theme(bool value) => _saveToDisk(PreferenceVariables.theme, value);
  set removeTheme(String key) => _remove(key);

  Future<String?> getString(String prefernceName) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefernceName);
  }

  Future setString(String prefernceName, String value) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefernceName, value);
  }

  Future<bool?> getBool(String prefernceName) async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefernceName) ?? false;
  }

  Future setBool(String prefernceName, bool value) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefernceName, value);
  }

  Future remove(String prefernceName) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefernceName);
  }

  Future putSharedPrefBoolValue(String key, bool value) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getSharedPrefBoolValue(String key) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool(key);
  }
}
