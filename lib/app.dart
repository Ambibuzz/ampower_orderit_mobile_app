import 'dart:io';

import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/app_viewmodel.dart';
import 'package:orderit/lifecycle_manager.dart';
import 'package:orderit/common/services/dialog_manager.dart';
import 'package:orderit/config/theme_model.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/common/services/connectivity_service.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'route/router.dart' as router;

class App extends StatefulWidget {
  final bool? login;
  App({this.login, super.key});
  static var storageService = locator.get<StorageService>();

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  var _packageInfo = PackageInfo();

  @override
  void initState() {
    super.initState();
    getPackageData();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getPackageData() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    _packageInfo = await PackageManager.getPackageInfo();
    // Locale myLocale = Localizations.localeOf(context);
    // print('LOCALE: ${myLocale.languageCode} || ${myLocale.countryCode}');
    if (Platform.isAndroid) {
      var manager = InAppUpdateManager();
      var appUpdateInfo = await manager.checkForUpdate();
      if (appUpdateInfo == null) return;
      if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        //If an in-app update is already running, resume the update.
        var message =
            await manager.startAnUpdate(type: AppUpdateType.immediate);
        debugPrint(message ?? '');
      } else if (appUpdateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        ///Update available
        if (appUpdateInfo.immediateAllowed) {
          var message =
              await manager.startAnUpdate(type: AppUpdateType.immediate);
          debugPrint(message ?? '');
        } else if (appUpdateInfo.flexibleAllowed) {
          var message =
              await manager.startAnUpdate(type: AppUpdateType.flexible);
          debugPrint(message ?? '');
        } else {
          debugPrint(
              'Update available. Immediate & Flexible Update Flow not allow');
        }
      }
    } else if (Platform.isIOS) {
      var _versionInfo = await UpgradeVersion.getiOSStoreVersion(
        packageInfo: _packageInfo,
      );
      debugPrint(_versionInfo.toJson().toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AppViewModel>(
      onModelReady: (model) async {},
      builder: (context, model, child) {
        return LifeCycleManager(
          child: StreamProvider<ConnectivityStatus>(
            initialData: ConnectivityStatus.wifi,
            create: (context) => locator
                .get<ConnectivityService>()
                .connectivityStatusController
                .stream,
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<ThemeModel>(
                  create: (_) => ThemeModel(),
                ),
              ],
              child: Consumer(
                builder: (context, ThemeModel themeNotifier, _) {
                  bool? isDark = themeNotifier.isDark;

                  var theme = isDark
                      ? CustomTheme.darkTheme(
                          primaryColor: CustomTheme.primaryColorDark)
                      : CustomTheme.lightTheme(
                          primaryColor: CustomTheme.primaryColorLight);
                  return MaterialApp(
                    title: 'AmPower OrderIT',
                    onGenerateRoute: router.generateRoute,
                    navigatorKey: locator.get<NavigationService>().navigatorKey,
                    builder: (context, child) => Navigator(
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => DialogManager(
                          child: MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaleFactor: 1.0),
                              child: child ?? const SizedBox.shrink()),
                        ),
                      ),
                    ),
                    localizationsDelegates: const [
                      FormBuilderLocalizations.delegate,
                    ],
                    initialRoute: (widget.login == true
                        ? splashViewRoute
                        : (loginViewRoute)),
                    debugShowCheckedModeBanner: false,
                    theme: theme,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
