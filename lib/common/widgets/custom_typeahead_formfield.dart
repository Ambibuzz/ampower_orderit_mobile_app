import 'dart:async';

import 'package:orderit/config/theme.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomTypeAheadFormField extends StatelessWidget {
  const CustomTypeAheadFormField({
    super.key,
    this.autoFlipDirection = true,
    required this.label,
    this.labelStyle,
    this.required = false,
    this.hideSuggestionOnKeyboardHide = false,
    this.controller,
    this.focusNode,
    this.onEditingComplete,
    required this.decoration,
    this.keyboardType = TextInputType.text,
    this.padding = EdgeInsets.zero,
    this.style,
    this.textInputAction = TextInputAction.next,
    this.validator,
    required this.onSuggestionSelected,
    required this.itemBuilder,
    required this.suggestionsCallback,
    this.transitionBuilder,
  });
  final String? label;
  final TextStyle? labelStyle;
  final bool? required;
  final bool hideSuggestionOnKeyboardHide;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final EdgeInsetsGeometry padding;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(dynamic) onSuggestionSelected;
  final Widget Function(BuildContext, dynamic) itemBuilder;
  final FutureOr<List<dynamic>?> Function(String) suggestionsCallback;
  final Widget Function(BuildContext, Animation<double>, Widget)?
      transitionBuilder;
  final bool autoFlipDirection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          TypeAheadField(
            controller: controller,
            autoFlipDirection: autoFlipDirection,
            builder: (context, controller, focusNode) {
              return TextFormField(
                keyboardType: keyboardType,
                style: style,
                controller: controller,
                focusNode: focusNode,
                validator: validator,
                decoration: decoration.copyWith(
                    label: Text(
                  label ?? '',
                  style: Sizes.textAndLabelStyle(context)?.copyWith(
                    color: CustomTheme.iconColor,
                  ),
                )),
              );
            },
            hideWithKeyboard: hideSuggestionOnKeyboardHide,
            onSelected: onSuggestionSelected,
            itemBuilder: itemBuilder,
            suggestionsCallback: suggestionsCallback,
            transitionBuilder: transitionBuilder,
            hideOnSelect: true,
            hideOnUnfocus: true,
          ),
        ],
      ),
    );
  }
}
