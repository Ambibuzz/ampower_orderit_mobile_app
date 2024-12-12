import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/config/colors.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/item_attributes_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:flutter/material.dart';

class ItemAttributesView extends StatelessWidget {
  ItemAttributesView({super.key, required this.item});
  ItemsModel item;

  @override
  Widget build(BuildContext context) {
    return BaseView<ItemAttributesViewModel>(
      onModelReady: (model) async {
        await model.getVariants(item);
      },
      builder: (context, model, child) {
        return ItemVariants(
          model: model,
          width: displayWidth(context) < 600 ? 160 : 230,
          buttonDimension: displayWidth(context) < 600 ? 30 : 40,
          priceStyle: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.bold),
          itemNameStyle: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.bold),
        );
      },
    );
  }
}

class ItemVariants extends StatelessWidget {
  final ItemAttributesViewModel model;
  final double? width;
  final double? buttonDimension;
  final TextStyle? priceStyle;
  final TextStyle? itemNameStyle;
  const ItemVariants({
    super.key,
    required this.model,
    this.width,
    this.buttonDimension,
    this.priceStyle,
    this.itemNameStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(
        bottom: Sizes.paddingWidget(context) * 1.8,
      ),
      shape: const RoundedRectangleBorder(borderRadius: Corners.xxlBorder),
      child: SizedBox(
        height: displayWidth(context) < 600 ? 340 : 430,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(
                    top: Sizes.smallPaddingWidget(context),
                    left: Sizes.smallPaddingWidget(context)),
                child: Row(
                  children: [
                    GestureDetector(
                      key: const Key(Strings.close),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close),
                    ),
                    SizedBox(width: Sizes.paddingWidget(context)),
                    Text('Select Variants (${model.itemFromVariants.length})',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Sizes.fontSizeTextButtonWidget(context))),
                  ],
                ),
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            Expanded(
              flex: 8,
              child: ListView.builder(
                padding:
                    EdgeInsets.only(left: Sizes.smallPaddingWidget(context)),
                scrollDirection: Axis.horizontal,
                itemCount: model.itemFromVariants.length,
                itemBuilder: (context, index) {
                  var item = model.itemFromVariants[index];
                  var itemQuantity = 0;
                  // set item quantity
                  var cartItems = locator.get<CartPageViewModel>().items;
                  if (cartItems != null) {
                    for (var i = 0; i < cartItems.length; i++) {
                      if (cartItems[i].itemCode == item.itemCode) {
                        itemQuantity = cartItems[i].quantity;
                      }
                    }
                  }
                  return gridTile(item, itemQuantity, index, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gridTile(
      ItemsModel item, int itemQuantity, int index, BuildContext context) {
    return GestureDetector(
      onTap: () =>
          locator.get<ItemsViewModel>().navigateToItemDetailPage(item, context),
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: Corners.xxlBorder),
        child: Container(
          key: Key(item.itemName ?? ''),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.smallPaddingWidget(context) * 0.4,
              vertical: Sizes.smallPaddingWidget(context) * 1,
            ),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    item.imageUrl == null
                        ? Container(
                            width: width,
                            height: width,
                            decoration: const BoxDecoration(
                              // borderRadius: Corners.xxlBorder,
                              image: DecorationImage(
                                image: AssetImage(
                                  Images.imageNotFound,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: locator.get<StorageService>().apiUrl +
                                item.imageUrl!,
                            httpHeaders: {
                              HttpHeaders.cookieHeader: DioHelper.cookies ?? ''
                            },
                            width: width,
                            height: width,
                            placeholder: (context, url) =>
                                const Icon(Icons.error),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                    SizedBox(height: displayWidth(context) < 600 ? 5 : 10),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Sizes.smallPadding,
                            right: Sizes.smallPadding,
                          ),
                          child: SizedBox(
                            child: Text(
                              item.itemName ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: itemNameStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: Sizes.smallPadding,
                        left: Sizes.smallPadding,
                      ),
                      child: Text(
                        item.price.toString(),
                        style: priceStyle,
                      ),
                    ),
                  ],
                ),
                item.hasVariants == 1
                    ? TextButton(
                        onPressed: () async {
                          await model.getVariants(item);
                        },
                        child: const Text('Variants'),
                      )
                    : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    item.hasVariants == 1
                        ? Container()
                        : incDecBtn(
                            model: model,
                            width: width,
                            buttonDimension: buttonDimension,
                            priceStyle: priceStyle,
                            itemNameStyle: itemNameStyle,
                            item: item,
                            context: context,
                            itemQuantity: itemQuantity,
                            index: index),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget incDecBtnPadding(BuildContext context) {
    return SizedBox(
      width:
          displayWidth(context) < 600 ? 0 : Sizes.smallPaddingWidget(context),
    );
  }

  Widget incDecBtn(
      {required ItemAttributesViewModel model,
      required double? width,
      required double? buttonDimension,
      required TextStyle? priceStyle,
      required TextStyle? itemNameStyle,
      required ItemsModel item,
      required BuildContext context,
      required int itemQuantity,
      required int index}) {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    return itemQuantity != 0
        ? Row(
            children: [
              GestureDetector(
                onTap: () {
                  model.remove(item, context, itemQuantity);
                  model.decrementQuantityControllerText(
                      index, model.quantityControllerList[index].text);
                },
                child: Container(
                  width: buttonDimension,
                  height: buttonDimension,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Theme.of(context).primaryColor,
                    key: Key('${Strings.decrementButtonKey}${item.itemCode}'),
                  ),
                ),
              ),
              incDecBtnPadding(context),
              SizedBox(
                width: 50,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: model.quantityControllerList[index],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: Sizes.extraSmallPaddingWidget(context)),
                    fillColor: Colors.transparent,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  style: Sizes.textAndLabelStyle(context),
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
                            .firstWhere((e) => e.itemCode == item.itemCode);
                        var index =
                            cartPageViewModel.items.indexOf(cartItemObj);
                        await cartPageViewModel.remove(index, context);
                      }
                    }
                  },
                ),
              ),
              incDecBtnPadding(context),
              GestureDetector(
                onTap: () {
                  model.add(item, context);
                  model.incrementQuantityControllerText(
                      index, model.quantityControllerList[index].text);
                },
                child: Container(
                  width: buttonDimension,
                  height: buttonDimension,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                    key: Key('${Strings.incrementButtonKey}${item.itemCode}'),
                  ),
                ),
              ),
            ],
          )
        : Padding(
            padding: EdgeInsets.only(
              right: displayWidth(context) < 600
                  ? Sizes.extraSmallPaddingWidget(context)
                  : Sizes.smallPaddingWidget(context),
            ),
            child: ElevatedButton(
              key: Key('${Strings.addToCart}${item.itemCode}}'),
              onPressed: () {
                model.setQty(index, '1', context);
                // model.add(item, context);
                model.incrementQuantityControllerText(
                    index, model.quantityControllerList[index].text);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Sizes.smallPaddingWidget(context)),
                child: Text(
                  Strings.addToCart,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          );
  }
}
