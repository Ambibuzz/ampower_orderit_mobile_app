import 'dart:async';
import 'package:camera/camera.dart';
import 'package:orderit/app.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/util/helpers.dart';
import 'package:orderit/util/preference.dart';
import 'package:flutter/material.dart';
import 'util/dio_helper.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    await setUpLocator();
    await initDb();
    await DioHelper.initApiConfig();
    bool? login = false;
    login = await locator
        .get<StorageService>()
        .getBool(PreferenceVariables.loggedIn);
    runApp(App(login: login));
  } catch (e) {
    exception(e, '', 'main');
  }
}
