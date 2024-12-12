import 'dart:io';

import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/item_category_bottom_nav_bar_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/success_viewmodel.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/config/styles.dart';

import 'package:orderit/base_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SuccessView extends StatelessWidget {
  final String? name;
  final String? doctype;
  const SuccessView({super.key, this.name, this.doctype});

  static var successColor = CustomTheme.successColor;

  @override
  Widget build(BuildContext context) {
    return BaseView<SuccessViewModel>(
      onModelReady: (model) async {},
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: displayHeight(context) * 0.18),
                    SizedBox(
                      width: displayWidth(context) - Sizes.padding,
                      height: displayWidth(context) < 600 ? 300 : 400,
                      child: const RiveAnimation.asset(
                        Images.checkAmination,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Woo-hoo!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                  letterSpacing: 1.5,
                                  color: successColor,
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: Sizes.paddingWidget(context),
                        ),
                        Text(
                          'Your Sales Order is created Successfully.',
                          maxLines: 2,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(
                          height: Sizes.extraSmallPaddingWidget(context),
                        ),
                        Text(
                          name ?? '',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(
                          height: Sizes.paddingWidget(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: Sizes.paddingWidget(context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  continueWidget(context),
                  sharePdf(model, context),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // widget to close current screen and go to home page
  Widget continueWidget(BuildContext context) {
    return Container(
      key: const Key(TestCasesConstants.closeButton),
      width: displayWidth(context) * 0.5 - Sizes.mediumPadding,
      height: Sizes.buttonHeightWidget(context),
      decoration: const BoxDecoration(
          borderRadius: Corners.xxlBorder, color: Colors.white),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(successColor),
        ),
        onPressed: () async {
          if (locator.get<StorageService>().isUserCustomer) {
            await locator
                .get<NavigationService>()
                .pushNamedAndRemoveUntil(itemCategoryNavBarRoute, (_) => false);
            locator.get<ItemCategoryBottomNavBarViewModel>().setIndex(0);
            locator.get<ItemsViewModel>().updateCartItems();
            await locator.get<ItemsViewModel>().initQuantityController();
          } else {
            await locator
                .get<NavigationService>()
                .pushNamedAndRemoveUntil(enterCustomerRoute, (_) => false);
          }
        },
        child: Text(
          'Continue',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      ),
    );
  }

  // share pdf via flutter share package
  Widget sharePdf(SuccessViewModel model, BuildContext context) {
    return Container(
      key: const Key(Strings.sharePdf),
      width: displayWidth(context) * 0.5 - Sizes.mediumPadding,
      height: Sizes.buttonHeightWidget(context),
      decoration: BoxDecoration(
        border: Border.all(
          color: successColor,
        ),
        borderRadius: Corners.xxlBorder,
        color: Colors.white,
      ),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
        ),
        onPressed: () async {
          if (Platform.isAndroid) {
            if (doctype != null && name != null) {
              var path = await locator
                  .get<CommonService>()
                  .pdfFromDocName(doctype!, name!);
              if (path.isNotEmpty) {
                await model.shareFile(path, 'Share Pdf', '$doctype - $name');
              }
            } else {
              showSnackBar('Doctype or Doc name is missing', context);
            }
          } else {
            flutterStyledToast(
                context,
                'Share Feature not supported for current platform',
                Theme.of(context).colorScheme.surface);
          }
        },
        child: Text(
          'Share',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: successColor,
              ),
        ),
      ),
    );
  }
}
