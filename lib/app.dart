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
import 'package:new_version_plus/new_version_plus.dart';
import 'package:provider/provider.dart';
import 'route/router.dart' as router;

class App extends StatelessWidget {
  final bool? login;
  App({this.login, super.key});
  static var storageService = locator.get<StorageService>();

  void basicStatusCheck(NewVersionPlus newVersion, BuildContext context) {
    try {
      if (!kDebugMode) {
        newVersion.showAlertIfNecessary(context: context);
      }
    } catch (e) {
      exception(e, '', 'basicStatusCheck');
    }
  }

  void advancedStatusCheck(
      NewVersionPlus newVersion, BuildContext context) async {
    try {
      final status = await newVersion.getVersionStatus();
      if (status != null) {
        debugPrint(status.releaseNotes);
        debugPrint(status.appStoreLink);
        debugPrint(status.localVersion);
        debugPrint(status.storeVersion);
        debugPrint(status.canUpdate.toString());
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: 'Custom Title',
          dialogText: 'Custom Text',
        );
      }
    } catch (e) {
      exception(e, '', 'advancedStatusCheck');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<AppViewModel>(
      onModelReady: (model) async {
        final newVersion = NewVersionPlus();
        basicStatusCheck(newVersion, context);
      },
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
                    initialRoute:
                        (login == true ? splashViewRoute : (loginViewRoute)),
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
