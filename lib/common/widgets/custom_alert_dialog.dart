import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CustomAlertDialog {
  Future alertDialog(
      String? heading,
      String? content,
      String? cancelButtonText,
      String? okButtonText,
      void Function()? cancelBtnOnPress,
      void Function()? okBtnOnPress,
      BuildContext context) async {
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
                heading ?? '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: CustomTheme.dangerColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        content: Text(
          content ?? '',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: CustomTheme.borderColor,
              ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: Sizes.buttonHeightWidget(context),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).scaffoldBackgroundColor),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          side: BorderSide(color: CustomTheme.borderColor),
                          borderRadius: Corners.xxlBorder,
                        ),
                      ),
                    ),
                    onPressed: cancelBtnOnPress,
                    child: Text(
                      cancelButtonText ?? '',
                      style: TextStyle(color: CustomTheme.borderColor),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: Sizes.smallPaddingWidget(context),
              ),
              Expanded(
                child: Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: SizedBox(
                    height: Sizes.buttonHeightWidget(context),
                    child: TextButton.icon(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          CustomTheme.dangerColor,
                        ),
                      ),
                      onPressed: okBtnOnPress,
                      label: Text(okButtonText ?? ''),
                      icon: Icon(Icons.arrow_back),
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
