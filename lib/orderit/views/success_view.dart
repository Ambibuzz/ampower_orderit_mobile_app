import 'dart:io';

import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/common/widgets/custom_typeahead_formfield.dart';
import 'package:orderit/common/widgets/typeahead_widgets.dart';
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
import 'package:orderit/util/enums.dart';
import 'package:rive/rive.dart';

class SuccessView extends StatelessWidget {
  final String? name;
  final String? doctype;
  const SuccessView({super.key, this.name, this.doctype});

  static var successColor = CustomTheme.successColor;

  @override
  Widget build(BuildContext context) {
    return BaseView<SuccessViewModel>(
      onModelReady: (model) async {
        model.init();
        await model.getPrintFormat();
      },
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.padding),
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
                                  height:
                                      Sizes.extraSmallPaddingWidget(context),
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
                      SizedBox(
                        height: Sizes.paddingWidget(context),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          downloadPdf(model, context),
                        ],
                      ),
                    ],
                  ),
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
          await showDialogToEnterPrintFormat(model, context, () async {
            Navigator.of(context, rootNavigator: true).pop();
            if (Platform.isAndroid) {
              if (doctype != null && name != null) {
                var path = await locator
                    .get<CommonService>()
                    .downloadSalesOrder(
                        doctype!, name!, model.printFormatController.text);
                if (path.isNotEmpty) {
                  await model.shareFile(path, 'Share Pdf', '$doctype - $name');
                }
              } else {
                showSnackBar(
                    'Doctype or Doc name or Print Format is missing', context);
              }
            } else {
              flutterStyledToast(
                  context,
                  'Share Feature not supported for current platform',
                  Theme.of(context).colorScheme.surface);
            }
          });
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

  // download pdf
  Widget downloadPdf(SuccessViewModel model, BuildContext context) {
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
          await showDialogToEnterPrintFormat(model, context, () async {
            Navigator.of(context, rootNavigator: true).pop();
            await model.downloadSalesOrder(doctype!, name!, context);
          });
        },
        child: Text(
          'Download PDF',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: successColor,
              ),
        ),
      ),
    );
  }

  Widget printFormatField(SuccessViewModel model, BuildContext context) {
    return CustomTypeAheadFormField(
      key: const Key(Strings.customerField),
      controller: model.printFormatController,
      decoration: Common.inputDecoration(),
      label: 'Select Print Format',
      required: true,
      style: Sizes.textAndLabelStyle(context),
      labelStyle: Sizes.textAndLabelStyle(context),
      itemBuilder: (context, item) {
        return TypeAheadWidgets.itemUi(item, context);
      },
      onSuggestionSelected: (suggestion) async {
        model.printFormatController.text = suggestion;
        FocusManager.instance.primaryFocus?.unfocus();
      },
      suggestionsCallback: (pattern) {
        return TypeAheadWidgets.getSuggestions(pattern, model.printFormatList);
      },
      transitionBuilder: (context, controller, suggestionsBox) {
        return suggestionsBox;
      },
      validator: (val) =>
          val == '' || val == null ? 'Please Select the Customer' : null,
    );
  }

  Future showDialogToEnterPrintFormat(SuccessViewModel model,
      BuildContext context, void Function()? onConfirmPressed) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        insetPadding:
            EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Sizes.paddingWidget(context),
          vertical: Sizes.paddingWidget(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Please Enter Print Format   ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            SizedBox(width: Sizes.smallPaddingWidget(context)),
            GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Icon(Icons.clear))
          ],
        ),
        content: SizedBox(height: 60, child: printFormatField(model, context)),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: Sizes.buttonHeightWidget(context),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.secondary),
                    ),
                    onPressed: onConfirmPressed,
                    child: const Text(
                      'Confirm',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
