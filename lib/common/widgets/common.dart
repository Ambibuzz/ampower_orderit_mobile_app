import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:orderit/common/models/user.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/config/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Common {
  static AppBar commonAppBar(
      String? title, List<Widget>? actions, BuildContext context,
      {bool? sendResultBack, bool? showBackBtn = true}) {
    return AppBar(
      title: Text(
        title ?? '',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
      ),
      leadingWidth: 36,
      leading: showBackBtn == true
          ? Navigator.of(context).canPop()
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
                        child: Image.asset(
                          Images.backButtonIcon,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ],
                )
              : null
          : null,
      titleSpacing: Sizes.smallPaddingWidget(context) * 1.5,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Corners.xlRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF006CB5), // Starting color
              Color(0xFF002D4C) // ending color
            ],
          ),
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Corners.xlRadius,
        ),
      ),
    );
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
        child: Common.userImage(context, user),
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

  static Widget userImage(BuildContext context, User user) {
    var imageDimension = 32.0;

    return user.userImage != null
        ? ClipOval(
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl:
                  '${locator.get<StorageService>().apiUrl}${user.userImage}',
              httpHeaders: {HttpHeaders.cookieHeader: DioHelper.cookies ?? ''},
              width: imageDimension,
              height: imageDimension,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Icon(Icons.error),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
                user.firstName != null ? user.firstName![0] : '',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
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
