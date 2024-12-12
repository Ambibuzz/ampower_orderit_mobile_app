import 'package:dio/dio.dart';
import 'package:orderit/config/colors.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rive/rive.dart';

//It displays toast message throughout the app

Future fluttertoast(Color textColor, Color backgroundColor, String message,
    BuildContext context) {
  return flutterStyledToast(
    context,
    message,
    backgroundColor,
    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textColor,
        ),
  );
}

Future flutterSimpleToast(
    Color textColor, Color backgroundColor, String message) {
  return Fluttertoast.showToast(
      msg: message,
      textColor: textColor,
      backgroundColor: backgroundColor,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG);
}

Future showErrorToast(Response<dynamic>? response) async {
  if (response?.data['message'] != null) {
    await flutterSimpleToast(
        Colors.white, Colors.black, response?.data['message']);
  } else {
    await flutterSimpleToast(Colors.white, Colors.black,
        'Something Went Wrong! Please re-login or contact support@ambibuzz.com');
  }
}

flutterStyledToast(BuildContext context, String message, Color backgroundColor,
    {TextStyle? textStyle, StyledToastPosition? position}) {
  return showToast(message,
      backgroundColor: backgroundColor,
      context: context,
      textStyle: textStyle,
      animation: StyledToastAnimation.slideFromTop,
      // reverseAnimation: StyledToastAnimation.slideToTop,
      position: position ?? StyledToastPosition.bottom,
      // startOffset: const Offset(0.0, -3.0),
      // reverseEndOffset: const Offset(0.0, -3.0),
      duration: const Duration(seconds: 3),
      borderRadius: Corners.xlBorder,
      animDuration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn);
}
