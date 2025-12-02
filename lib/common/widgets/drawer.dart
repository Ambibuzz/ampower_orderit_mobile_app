import 'package:orderit/common/services/logout_api_service.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';

Drawer drawer(BuildContext context, DrawerMenu appSelected) {
  var model = locator.get<ItemsViewModel>();
  var imageIconDimension = displayWidth(context) < 600 ? 28.0 : 32.0;

  return Drawer(
    child: SizedBox(
      height: displayHeight(context),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: DrawerHeader(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 30,
                        child: Common.userImage(context, imgDimension: 80),
                      ),
                      SizedBox(width: Sizes.paddingWidget(context)),
                      Expanded(
                        flex: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.user.fullName ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Sizes.titleTextStyle(context)?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              model.user.email ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Sizes.subTitleTextStyle(context),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: Sizes.paddingWidget(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getAppSelected(appSelected),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                              height: Sizes.extraSmallPaddingWidget(context)),
                          Text(
                            'B2B Sales Order Management',
                            style: Sizes.subTitleTextStyle(context)?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.borderColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Sizes.smallPaddingWidget(context)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: listTileImageWidget(
                      Images.customerSelectionIcon, imageIconDimension),
                  title: listTileTitleWidget('Customer Selection', context),
                  onTap: () async {
                    Navigator.pop(context);
                    await locator
                        .get<NavigationService>()
                        .pushReplacementNamed(enterCustomerRoute);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: listTileImageWidget(
                      Images.profileIcon, imageIconDimension),
                  title: listTileTitleWidget('Profile', context),
                  onTap: () async {
                    Navigator.pop(context);
                    await locator
                        .get<NavigationService>()
                        .pushReplacementNamed(profileViewRoute);
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes.paddingWidget(context),
              ),
              width: displayWidth(context),
              height: Sizes.buttonHeightWidget(context),
              child: TextButton.icon(
                onPressed: () async {
                  await locator.get<LogoutService>().logOut(context);
                },
                label: Text(
                  'Logout',
                  style: Sizes.titleTextStyle(context)?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
                icon: const Icon(Icons.logout),
              ),
            ),
          ),
          SizedBox(height: Sizes.paddingWidget(context)),
        ],
      ),
    ),
  );
}

Widget listTileImageWidget(String image, double? imageIconDimension) {
  return Image.asset(
    image,
    width: imageIconDimension,
  );
}

Widget listTileTitleWidget(String? text, BuildContext context) {
  return Text(
    text ?? '',
    style: Sizes.titleTextStyle(context)?.copyWith(fontWeight: FontWeight.bold),
  );
}

String getAppSelected(DrawerMenu appSelected) {
  if (appSelected == DrawerMenu.orderit) {
    return 'AmPower OrderIT';
  } else if (appSelected == DrawerMenu.buzzit) {
    return 'AmPower BuzzIT';
  } else {
    return 'AmPower TargetIT';
  }
}
