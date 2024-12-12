import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:flutter/material.dart';

class MaterialWidgetsFactory implements IWidgetsFactory {
  @override
  IActivityIndicator createActivityIndicator() {
    return AndroidActivityIndicator();
  }

  @override
  String getTitle() {
    return 'Android Widgets';
  }

  @override
  IBackButton createBackButtonIcon() {
    return AndroidBackButton();
  }
}

class AndroidActivityIndicator implements IActivityIndicator {
  @override
  Widget render() {
    return const CircularProgressIndicator(
      color: CustomTheme.primarycolor,
    );
  }
}

class AndroidBackButton implements IBackButton {
  @override
  Widget render() {
    return Padding(
      padding: const EdgeInsets.only(
        left: Sizes.smallPadding,
      ),
      child: GestureDetector(
        onTap: () => locator.get<NavigationService>().pop(),
        child: ImageIcon(
          const AssetImage(
            Images.backButtonIcon,
          ),
          color: CustomTheme.primaryColorLight,
        ),
      ),
    );
  }
}
