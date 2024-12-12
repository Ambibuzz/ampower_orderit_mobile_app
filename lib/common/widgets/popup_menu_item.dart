import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';

// show popup menu item
class CustomPopUpMenu {
  static PopupMenuItem<ViewTypes> viewTypeMenu(
      String title, ViewTypes value, String icon, BuildContext context) {
    return PopupMenuItem(
      height: 30,
      value: value,
      child: Row(
        children: [
          Image.asset(icon, width: 20, height: 20),
          SizedBox(
            width: Sizes.smallPaddingWidget(context),
          ),
          Text(
            title,
          ),
          const Spacer(),
          locator.get<ItemsViewModel>().viewType == value
              ? Icon(
                  Icons.done,
                  color: CustomTheme.iconColor,
                  size: 24,
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
