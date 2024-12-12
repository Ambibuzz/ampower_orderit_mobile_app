import 'package:orderit/config/theme.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.label,
    this.labelStyle,
    this.required = false,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.style,
    this.validator,
    this.onEditingComplete,
    this.onTap,
    this.focusNode,
    this.padding = EdgeInsets.zero,
    this.decoration,
    this.textInputAction = TextInputAction.next,
    this.readOnly = false,
    this.onChanged,
    this.initialValue,
    this.maxLines = 1,
  });

  final String? label;
  final bool? required;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final String? Function(String?)? validator;
  final void Function()? onEditingComplete;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;
  final InputDecoration? decoration;
  final TextStyle? labelStyle;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final void Function(String)? onChanged;
  final String? initialValue;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            focusNode: focusNode,
            obscureText: obscureText,
            onChanged: onChanged,
            style: style,
            validator: validator,
            initialValue: initialValue,
            textInputAction: textInputAction,
            onEditingComplete: onEditingComplete,
            onTap: onTap,
            decoration: decoration?.copyWith(
              label: Text(
                label ?? '',
                style: Sizes.textAndLabelStyle(context)?.copyWith(
                  color: CustomTheme.iconColor,
                ),
              ),
            ),
            readOnly: readOnly,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}
