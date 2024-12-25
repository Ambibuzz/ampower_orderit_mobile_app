import 'package:orderit/util/constants/sizes.dart';
import 'package:flutter/material.dart';

// show custom snackbar
void showSnackBar(String text, BuildContext context,
    {Color? backgroundColor, Duration? duration, Color? textColor}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: textColor ?? Theme.of(context).colorScheme.onSurface,
          ),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor:
        backgroundColor ?? Theme.of(context).snackBarTheme.backgroundColor,
    duration: duration ?? const Duration(seconds: Sizes.snackbarDuration),
    margin: const EdgeInsetsDirectional.symmetric(
        horizontal: Sizes.smallPadding, vertical: Sizes.smallPadding),
  ));
}
