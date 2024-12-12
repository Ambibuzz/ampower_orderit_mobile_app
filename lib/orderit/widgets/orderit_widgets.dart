import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/item_attributes_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';

class OrderitWidgets {
  static Future addToCart(Product product, BuildContext context,
      {StyledToastPosition? position}) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    var itemAttributesViewModel = locator.get<ItemAttributesViewModel>();
    var items =
        await locator.get<ItemsService>().mapProductToItemModel([product]);
    var item = items[0];
    final cartItem = Cart(
        id: item.itemCode,
        itemName: item.itemName,
        quantity: 1,
        itemCode: item.itemCode,
        rate: item.price,
        imageUrl: (item.images == null || item.images?.isEmpty == true)
            ? item.imageUrl
            : item.images![0].fileUrl);

    if (cartPageViewModel.existsInCart(cartPageViewModel.items, cartItem)) {
      itemAttributesViewModel.updateCartItems();
      await locator.get<ItemsViewModel>().updateCartItems();
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      //Increment quantity
      await cartPageViewModel.increment(index, context);
    } else {
      await cartPageViewModel.add(cartItem, context);
    }
    flutterStyledToast(
        context, 'Item Added to Cart', CustomTheme.onPrimaryColorLight,
        textStyle: TextStyle(color: CustomTheme.successColor));
    itemAttributesViewModel.updateCartItems();
    await locator.get<ItemsViewModel>().updateCartItems();
    await cartPageViewModel.initQuantityController();
  }

  static Widget customerNameReusableWidget(BuildContext context) {
    return Container(
      height: displayWidth(context) < 600 ? 40 : 50,
      width: displayWidth(context),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
        child: Row(
          children: [
            Text(
              (displayWidth(context) < 600 ? 'Customer' : 'Customer Name') +
                  ' : ${locator.get<StorageService>().customerSelected}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  static Widget emptyCartWidget(String? titleText, String? subtitleText,
      String? buttonText, void Function()? onButtonPress, BuildContext context,
      {double? imgDimension}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Sizes.paddingWidget(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Images.emptyCartImage,
              width: imgDimension ?? 300,
              height: imgDimension ?? 300,
            ),
            SizedBox(
              height: Sizes.paddingWidget(context),
            ),
            Text(
              titleText ?? '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Common.widgetSpacingVerticalMd(),
            Text(
              subtitleText ?? '',
              style: TextStyle(color: CustomTheme.borderColor),
              textAlign: TextAlign.center,
            ),
            Common.widgetSpacingVerticalMd(),
            ElevatedButton(
              onPressed: onButtonPress,
              child: Padding(
                padding: EdgeInsets.symmetric(
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
            ),
          ],
        ),
      ),
    );
  }

  // on Tap runs when screen is popped or back button is pressed
  static Widget floatingCartButton(BuildContext context, Function onTap) {
    return Positioned(
      bottom: Sizes.extraSmallPaddingWidget(context),
      left: 0,
      right: 0,
      child: locator.get<CartPageViewModel>().items.isNotEmpty == true
          ? GestureDetector(
              onTap: () async {
                var result = await locator
                    .get<NavigationService>()
                    .navigateTo(cartViewRoute);
                onTap;
                if (result != null) {
                  var res = result as List;
                  if (res[0] == true) {
                    onTap();
                  }
                }
              },
              child: Center(
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: Corners.xxlBorder),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.extraSmallPaddingWidget(context),
                      vertical: Sizes.extraSmallPaddingWidget(context),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              'View Cart',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                            ),
                            Text(
                              '${locator.get<CartPageViewModel>().items.length} items',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: Sizes.smallPaddingWidget(context),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).colorScheme.onSecondary,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Future toggleFavorite(String item, BuildContext context) async {
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    var favoritesList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedFavoritesData();

    if (favoritesList.isNotEmpty) {
      // when item is in favorite remove it
      if (favoritesList.contains(item)) {
        favoritesList.remove(item);
      }
      // when item not in favorite add it to favorite
      else {
        favoritesList.add(item);
      }
      await locator.get<DoctypeCachingService>().cacheFavoritesList(
          Strings.favoritesList, favoritesList, connectivityStatus);
    }
    // when list is empty
    else {
      await locator.get<DoctypeCachingService>().cacheFavoritesList(
          Strings.favoritesList, [item], connectivityStatus);
    }
  }
}
