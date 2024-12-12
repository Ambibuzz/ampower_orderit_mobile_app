import 'package:orderit/base_view.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/favorites_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/item_category_bottom_nav_bar_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../views/image_widget_native.dart'
    if (dart.library.html) 'image_widget_web.dart' as image_widget;

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<FavoritesViewModel>(
      onModelReady: (model) async {
        await model.getFavoritesItems();
        await model.getCartItems();
        await model.initQuantityController();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: Common.commonAppBar(
            'Favorites',
            [],
            context,
          ),
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : Stack(
                  children: [
                    model.favoriteItems.isNotEmpty
                        ? favoritesList(model, context)
                        : Center(
                            child: SizedBox(
                              height: displayHeight(context) * 0.7,
                              child: OrderitWidgets.emptyCartWidget(
                                  'No items in Favorites!', '', 'Let’s Shop!',
                                  () {
                                locator
                                    .get<ItemCategoryBottomNavBarViewModel>()
                                    .setIndex(0);
                                locator.get<ItemsViewModel>().updateCartItems();
                                locator
                                    .get<ItemsViewModel>()
                                    .initQuantityController();
                              }, context),
                            ),
                          ),
                    OrderitWidgets.floatingCartButton(context, () async {
                      await model.getFavoritesItems();
                      await model.initQuantityController();
                      await model.updateCartItems();
                      await model.getCartItems();
                      await model.refresh();
                    }),
                  ],
                ),
        );
      },
    );
  }

  Widget incDecBtn(
      {required FavoritesViewModel model,
      required double? width,
      required double? buttonDimension,
      required TextStyle? priceStyle,
      required TextStyle? itemNameStyle,
      required ItemsModel item,
      required BuildContext context,
      required int itemQuantity,
      required double? stockActualQty,
      required int index}) {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    var iconSize = displayWidth(context) < 600 ? 20.0 : 32.0;

    return SizedBox(
      width: displayWidth(context) < 600 ? 115 : 150,
      child: SizedBox(
        height: displayWidth(context) < 600 ? 37 : 42,
        child: itemQuantity == 0
            ? stockActualQty == 0.0
                ? Center(
                    child: Text(
                      'Out of Stock',
                      style: TextStyle(
                        color: CustomTheme.dangerColor,
                      ),
                    ),
                  )
                : TextButton(
                    key: Key('${Strings.addToCart}${item.itemCode}'),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surface),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            borderRadius: Corners.xxlBorder),
                      ),
                    ),
                    onPressed: () async {
                      await model.add(item, context);
                      await Future.delayed(const Duration(milliseconds: 200));
                      var controllerIndex = -1;
                      for (var i = 0;
                          i < model.quantityControllerList.length;
                          i++) {
                        if (model.quantityControllerList[i].id ==
                            item.itemCode) {
                          controllerIndex = i;
                        }
                      }
                      if (controllerIndex != -1) {
                        if (model.quantityControllerList[controllerIndex]
                                .controller !=
                            null) {
                          model.incrementQuantityControllerText(
                              controllerIndex,
                              model.quantityControllerList[controllerIndex]
                                  .controller!.text);
                        }
                        await model.refresh();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: displayWidth(context) < 600
                              ? Sizes.paddingWidget(context) * 2
                              : Sizes.paddingWidget(context)),
                      child: Text(
                        Strings.add,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                  )
            : (model.isQuantityControllerInitialized
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.extraSmallPaddingWidget(context),
                      vertical: Sizes.extraSmallPaddingWidget(context),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: Corners.xxlBorder,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cartControllerButton(
                            iconColor:
                                Theme.of(context).colorScheme.onSecondary,
                            iconSize: iconSize,
                            buttonDimension: buttonDimension,
                            icon: Icons.remove,
                            onPressed: () async {
                              await decrementController(
                                  item, itemQuantity, model, context);
                            },
                            key: Key(
                                '${Strings.decrementButtonKey}${item.itemCode}')),
                        model.quantityControllerList.isEmpty
                            ? const SizedBox()
                            : incDecController(
                                controller: model
                                    .quantityControllerList[index].controller,
                                onChanged: (String value) async {
                                  // value empty
                                  if (value.isEmpty) {
                                  }
                                  // not empty
                                  else {
                                    if (int.parse(value) != 0) {
                                      await model.setQty(index, value, context);
                                    }
                                    // if set to 0 then remove from cart
                                    if (int.parse(value) == 0) {
                                      var cartItemObj = cartPageViewModel.items
                                          .firstWhere((e) =>
                                              e.itemCode == item.itemCode);
                                      var index = cartPageViewModel.items
                                          .indexOf(cartItemObj);
                                      await cartPageViewModel.remove(
                                          index, context);
                                    }
                                  }
                                  await model.refresh();
                                },
                                underlineColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fillColor: Colors.transparent,
                                context: context,
                              ),
                        cartControllerButton(
                          iconColor: Theme.of(context).colorScheme.onSecondary,
                          iconSize: iconSize,
                          buttonDimension: buttonDimension,
                          icon: Icons.add,
                          onPressed: () async {
                            await incrementController(item, model, context);
                          },
                          key: Key(
                              '${Strings.incrementButtonKey}${item.itemCode}'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox()),
      ),
    );
  }

  Widget cartControllerButton(
      {Key? key,
      required Color iconColor,
      required double iconSize,
      required double? buttonDimension,
      required IconData icon,
      required void Function()? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: buttonDimension,
        height: buttonDimension,
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
          key: key,
        ),
      ),
    );
  }

  Widget incDecController(
      {required TextEditingController? controller,
      required void Function(String)? onChanged,
      required Color underlineColor,
      required Color? fillColor,
      required BuildContext context,
      Key? key}) {
    return SizedBox(
      width: displayWidth(context) < 600 ? 40 : 50,
      child: TextFormField(
        textAlign: TextAlign.center,
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 0, vertical: Sizes.extraSmallPaddingWidget(context)),
          fillColor: fillColor,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: underlineColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: underlineColor),
          ),
        ),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary),
        onChanged: onChanged,
      ),
    );
  }

  Future decrementController(ItemsModel item, int itemQuantity,
      FavoritesViewModel model, BuildContext context) async {
    await model.remove(item, context, itemQuantity);
    await Future.delayed(const Duration(milliseconds: 200));
    var controllerIndex = -1;
    for (var i = 0; i < model.quantityControllerList.length; i++) {
      if (model.quantityControllerList[i].id == item.itemCode) {
        controllerIndex = i;
      }
    }
    if (controllerIndex != -1) {
      if (model.quantityControllerList[controllerIndex].controller != null) {
        model.decrementQuantityControllerText(controllerIndex,
            model.quantityControllerList[controllerIndex].controller!.text);
      }
      await model.refresh();
    }
  }

  Future incrementController(
      ItemsModel item, FavoritesViewModel model, BuildContext context) async {
    await model.add(item, context);
    await Future.delayed(const Duration(milliseconds: 200));
    var controllerIndex = -1;
    for (var i = 0; i < model.quantityControllerList.length; i++) {
      if (model.quantityControllerList[i].id == item.itemCode) {
        controllerIndex = i;
      }
    }
    if (controllerIndex != -1) {
      if (model.quantityControllerList[controllerIndex].controller != null) {
        model.incrementQuantityControllerText(controllerIndex,
            model.quantityControllerList[controllerIndex].controller!.text);
      }
    }
    await model.getCartItems();
    await model.refresh();
  }

  Widget favoritesList(FavoritesViewModel model, BuildContext context) {
    return ListView.builder(
      itemCount: model.favoriteItems.length,
      padding:
          EdgeInsets.symmetric(vertical: Sizes.smallPaddingWidget(context)),
      itemBuilder: (context, index) {
        var item = model.favoriteItems[index];
        var itemQuantity = 0;
        // set item quantity
        var cartItems = locator.get<CartPageViewModel>().items;
        if (cartItems.isNotEmpty == true) {
          for (var i = 0; i < cartItems.length; i++) {
            if (cartItems[i].itemCode == item.itemCode) {
              itemQuantity = cartItems[i].quantity;
            }
          }
        }
        return favoriteTileWidget(item, itemQuantity, index, model, context);
      },
    );
  }

  Widget favoriteTileWidget(ItemsModel item, int itemQuantity, int index,
      FavoritesViewModel model, BuildContext context) {
    var imgDimension = displayWidth(context) < 600 ? 60.0 : 90.0;
    var isFavorite = model.isFavorite(item.itemCode!);
    var width = displayWidth(context) < 600 ? 124.0 : 180.0;
    var imageWidth = displayWidth(context) < 600 ? 110.0 : 170.0;
    var itemNameStyle = Theme.of(context).textTheme.titleSmall;
    var itemGroupStyle = Theme.of(context).textTheme.titleSmall;
    var priceStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);
    var buttonDimension = displayWidth(context) < 600 ? 30.0 : 40.0;
    var iconSize = displayWidth(context) < 600 ? 24.0 : 32.0;
    var stockActualQty =
        locator.get<ItemsViewModel>().getStockActualQty(item.itemCode);

    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: Sizes.paddingWidget(context),
          vertical: Sizes.smallPaddingWidget(context)),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: Sizes.smallPaddingWidget(context)),
        leading: ClipRRect(
          borderRadius: Corners.lgBorder,
          child: item.imageUrl == null || item.imageUrl == ''
              ? Container(
                  width: imgDimension,
                  height: imgDimension,
                  decoration: const BoxDecoration(
                    borderRadius: Corners.xxlBorder,
                    image: DecorationImage(
                      image: AssetImage(
                        Images.imageNotFound,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : item.imageUrl == null
                  ? Container()
                  : image_widget.imageWidget(
                      '${locator.get<StorageService>().apiUrl}${item.imageUrl}',
                      imgDimension,
                      imgDimension,
                      fit: BoxFit.fill),
        ),
        title: Text(item.itemName ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.itemCode ?? ''),
            Text(item.itemGroup ?? ''),
          ],
        ),
        onTap: () async {
          await locator
              .get<NavigationService>()
              .navigateTo(itemsDetailViewRoute, arguments: item.itemCode);
        },
        horizontalTitleGap: Sizes.smallPaddingWidget(context),
        trailing: SizedBox(
          width: displayWidth(context) < 600 ? 150 : 180,
          child: Row(
            children: [
              incDecBtn(
                  model: model,
                  width: width,
                  buttonDimension: buttonDimension,
                  priceStyle: priceStyle,
                  itemNameStyle: itemNameStyle,
                  item: item,
                  context: context,
                  itemQuantity: itemQuantity,
                  stockActualQty: stockActualQty,
                  index: index),
              SizedBox(width: Sizes.smallPaddingWidget(context)),
              GestureDetector(
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onTap: () => model.toggleFavorite(item.itemCode!, context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
