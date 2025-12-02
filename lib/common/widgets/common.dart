import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orderit/common/models/user.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/viewmodels/enter_customer_viewmodel.dart';
import 'package:orderit/common/widgets/custom_alert_dialog.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/config/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../orderit/views/image_widget_native.dart'
    if (dart.library.html) 'image_widget_web.dart' as image_widget;

class Common {
  static AppBar commonAppBar(
      String? title, List<Widget>? actions, BuildContext context,
      {bool? sendResultBack,
      String? heading,
      TextStyle? headingStyle,
      Widget? leading}) {
    return AppBar(
      title: Text(
        title ?? '',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: false,
      leadingWidth: 36,
      leading: leading != null
          ? leading
          : Navigator.of(context).canPop()
              ? Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: GestureDetector(
                        onTap: () => sendResultBack == true
                            ? locator.get<NavigationService>().pop(result: true)
                            : Navigator.of(context).pop(),
                        child: Icon(
                          defaultTargetPlatform == TargetPlatform.iOS
                              ? Icons.arrow_back_ios
                              : Icons.arrow_back,
                          size: 24,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
      shadowColor: Colors.black.withOpacity(0.4),
      titleSpacing: Sizes.smallPaddingWidget(context) * 1.5,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: actions,
    );
  }

  static double convertToDouble(dynamic data) {
    if (data is int) {
      return (data).toDouble();
    } else {
      return data;
    }
  }

  static Future<bool> showExitConfirmationDialog(BuildContext context) async {
    return await CustomAlertDialog().alertDialog(
          'Are you sure you want to exit?',
          '',
          'Stay',
          'Exit',
          () => Navigator.of(context, rootNavigator: true).pop(false),
          () => Navigator.of(context, rootNavigator: true).pop(true),
          context,
          headingTextColor: CustomTheme.secondaryColorLight,
          okBtnBgColor: CustomTheme.secondaryColorLight,
          cancelColor: CustomTheme.secondaryColorLight,
        ) ??
        false;
  }

  static Widget appBarIcon(Color iconColor, String text, IconData icon,
      Color bgColor, bool isSelected, String route, BuildContext context,
      {dynamic args, Key? key}) {
    var imageSize = displayWidth(context) < 600 ? 24.0 : 32.0;
    var textSize = displayWidth(context) < 400
        ? 11.0
        : (displayWidth(context) < 600
            ? 12.0
            : (displayWidth(context) < 800 ? 14.0 : 17.0));
    return GestureDetector(
      key: key,
      onTap: () {
        // if already selected dont navigate
        if (isSelected) {
        }
        // if not selected then only navigate
        else {
          locator
              .get<NavigationService>()
              .pushReplacementNamed(route, arguments: args);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: imageSize,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          SizedBox(height: Sizes.extraSmallPaddingWidget(context)),
          Text(
            text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: textSize),
          ),
          SizedBox(height: Sizes.extraSmallPaddingWidget(context)),
          isSelected
              ? Container(
                  width: displayWidth(context) < 600 ? 30 : 40,
                  height: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                )
              : const SizedBox()
        ],
      ),
    );
  }

  static Widget hamburgerMenuWidget(
      GlobalKey<ScaffoldState> key, BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.menu,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () => key.currentState?.openDrawer(),
    );
  }

  static Widget bottomSheetHeader(BuildContext context) {
    return Container(
      width: 60,
      height: 3,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: Corners.xxlBorder,
      ),
    );
  }

  static Widget textButtonWithIcon(
      String? buttonText, void Function()? onButtonPress, BuildContext context,
      {EdgeInsetsGeometry? padding}) {
    return ElevatedButton(
      onPressed: onButtonPress,
      child: Padding(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: Sizes.paddingWidget(context),
              vertical: Sizes.smallPaddingWidget(context),
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              buttonText ?? '',
            ),
            SizedBox(
              width: Sizes.smallPaddingWidget(context),
            ),
            const Icon(Icons.arrow_forward)
          ],
        ),
      ),
    );
  }

  static Widget widgetSpacingVerticalSm() {
    return const SizedBox(height: Spacing.widgetSpacingSm);
  }

  static Widget widgetSpacingVerticalMd() {
    return const SizedBox(height: Spacing.widgetSpacingMd);
  }

  static Widget widgetSpacingVerticalLg() {
    return const SizedBox(height: Spacing.widgetSpacingLg);
  }

  static Widget widgetSpacingVerticalXl() {
    return const SizedBox(height: Spacing.widgetSpacingXl);
  }

  static Widget customIcon(
      String? icon, void Function()? onPressed, BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        icon ?? '',
        color: Theme.of(context).primaryColor,
        width: displayWidth(context) < 600 ? 28 : 48,
        height: displayWidth(context) < 600 ? 28 : 48,
      ),
    );
  }

  static Widget dividerHeader(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: Sizes.paddingWidget(context)),
        Container(
          width: 70,
          height: 3,
          decoration: BoxDecoration(
              color: Colors.grey[800], borderRadius: Corners.smBorder),
        ),
        SizedBox(height: Sizes.paddingWidget(context)),
      ],
    );
  }

  static Widget profileReusableWidget(User user, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: Sizes.smallPaddingWidget(context)),
      child: GestureDetector(
        onTap: () async {
          await locator.get<NavigationService>().navigateTo(
                profileViewRoute,
              );
        },
        child: Common.userImage(context),
      ),
    );
  }

  static Widget scrollToViewTableBelow(BuildContext context, {String? text}) {
    return Row(
      children: [
        Text(
          'Scroll ',
          style: displayWidth(context) < 600
              ? Theme.of(context).textTheme.titleSmall
              : Theme.of(context).textTheme.titleLarge,
        ),
        Icon(Icons.arrow_back, size: displayWidth(context) < 600 ? 18 : 32),
        Text(
          ' or ',
          style: displayWidth(context) < 600
              ? Theme.of(context).textTheme.titleSmall
              : Theme.of(context).textTheme.titleLarge,
        ),
        Icon(Icons.arrow_forward, size: displayWidth(context) < 600 ? 18 : 32),
        Text(
          text ?? ' to view table below',
          style: displayWidth(context) < 600
              ? Theme.of(context).textTheme.titleSmall
              : Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  static DataColumn tableColumnText(BuildContext context, String text) {
    return DataColumn(
      label: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  static DataCell dataCellText(BuildContext context, String text, double width,
      {int? maxlines = 2,
      TextOverflow? overflow = TextOverflow.ellipsis,
      TextStyle? textStyle}) {
    return DataCell(SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: maxlines,
        overflow: overflow,
        style: textStyle,
      ),
    ));
  }

  static Widget reusableRowWidget(
      String? key, String? value, BuildContext context,
      {TextStyle? textStyle}) {
    return Row(
      children: [
        Expanded(
            flex: 40,
            child: Text(
              '$key : ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFA2A2A2),
                fontSize: 14,
              ),
            )),
        Expanded(
            flex: 60,
            child: Text(
              value ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle ??
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
            )),
      ],
    );
  }

  static Widget reusableTextWidget(
      String? text, double textSize, BuildContext context,
      {Color? color, FontWeight? fontWeight}) {
    return SizedBox(
      child: Text(
        text ?? '',
        style: TextStyle(
          fontSize: displayWidth(context) < 600 ? textSize : textSize * 1.5,
          fontWeight: fontWeight ?? FontWeight.w700,
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  static Widget shoppingCartReusableWidget(
      BuildContext context, Function onTap) {
    return GestureDetector(
      onTap: () async {
        var result =
            await locator.get<NavigationService>().navigateTo(cartViewRoute);
        onTap;
        if (result != null) {
          var res = result as List;
          if (res[0] == true) {
            onTap();
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Sizes.extraSmallPaddingWidget(context),
          horizontal: Sizes.smallPaddingWidget(context),
        ),
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onSurface),
          borderRadius: Corners.lgBorder,
        ),
        child: Row(
          children: [
            Icon(
              Icons.shopping_cart,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(width: Sizes.smallPaddingWidget(context)),
            Text(
              '${Formatter.customFormatter(locator.get<ItemsViewModel>().currencySymbol).format((locator.get<CartPageViewModel>().total ?? 0.0))}',
              style: GoogleFonts.inter(
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: displayWidth(context) < 600 ? 15 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: Sizes.smallPaddingWidget(context)),
          ],
        ),
      ),
    );
  }

  static Widget userImage(BuildContext context, {double? imgDimension}) {
    var imageDimension = imgDimension ?? 32.0;
    var model = locator.get<EnterCustomerViewModel>();
    return model.user.userImage != null
        ? ClipOval(
            clipBehavior: Clip.antiAlias,
            child: image_widget.imageWidget(
              '${locator.get<StorageService>().apiUrl}${model.user.userImage}',
              imageDimension,
              imageDimension,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            width: imageDimension,
            height: imageDimension,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColorLight,
            ),
            child: Center(
              child: Text(
                model.user.firstName != null ? model.user.firstName![0] : '',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
  }

  static Widget currencyFormattedWidget(
      String? currency, double? value, TextStyle? style) {
    return FutureBuilder<String>(
      future: CommonService().getCurrencySymbolFromCurrency(currency ?? 'INR'),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            Formatter.formatter.format(value),
            style: style,
          );
        } else if (snapshot.hasError) {
          return Text(
            Formatter.formatter.format(value),
            style: style,
          );
        } else if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty == true) {
            return Text(
              Formatter.customFormatter(snapshot.data).format(value),
              style: style,
            );
          } else {
            return Text(
              Formatter.customFormatter(snapshot.data).format(value),
              style: style,
            );
          }
        } else {
          return Text(
            Formatter.customFormatter(snapshot.data).format(value),
            style: style,
          );
        }
      },
    );
  }

  static InputDecoration inputDecoration({
    Widget? suffixIcon,
    Widget? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      suffix: suffix,
    );
  }
}
