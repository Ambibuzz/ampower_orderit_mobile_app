import 'package:orderit/common/widgets/abstract_factory/cupertinowidgetsfactory.dart';
import 'package:orderit/common/widgets/abstract_factory/materialwidgetsfactory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class IWidgetsFactory {
  String getTitle();
  IActivityIndicator createActivityIndicator();
  IBackButton createBackButtonIcon();
}

abstract class IActivityIndicator {
  Widget render();
}

abstract class IBackButton {
  Widget render();
}

class WidgetsFactoryList {
  static List<IWidgetsFactory> widgetsFactoryList = [
    MaterialWidgetsFactory(),
    CupertinoWidgetsFactory()
  ];

  static Widget circularProgressIndicator() {
    var activityIndicator = defaultTargetPlatform == TargetPlatform.iOS
        ? widgetsFactoryList[1].createActivityIndicator()
        : widgetsFactoryList[0].createActivityIndicator();
    return Center(child: activityIndicator.render());
  }

  static Widget backButton() {
    var backButton = defaultTargetPlatform == TargetPlatform.iOS
        ? widgetsFactoryList[1].createBackButtonIcon()
        : widgetsFactoryList[0].createBackButtonIcon();
    return backButton.render();
  }
}
