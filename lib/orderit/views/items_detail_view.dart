import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_detail_viewmodel.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/config/theme_model.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

class ItemsDetailView extends StatelessWidget {
  final String? itemCode;
  const ItemsDetailView(this.itemCode, {super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ItemsDetailViewModel>(
      onModelReady: (model) async {
        //Try to add future.wait and test
        await model.init();
        await model.getCartItems();
        await model.getProduct(itemCode);
        await model.getItemPrices();
        // setup cart items to cart page
        await locator.get<CartPageViewModel>().setCartItems();
        await locator.get<CartPageViewModel>().initQuantityController();
        if (model.product.hasVariants == 1) {
          await model.getVariants();
          await model.getAttributesDropdownList();
        }

        // select 1 st variant by default if variants is present
        if (model.productsFromVariants.isNotEmpty) {
          await model.setIsSelected(0);
        }
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {}
        for (var cartItem in model.items) {
          if (cartItem.itemCode == model.product.itemCode) {
            var index = model.items.indexOf(cartItem);
            await model.setIndex(index);
            // model.setQuantity(cartItem.quantity);
            model.setItemInCartValue(true);
          }
        }
        model.updateQuantityController();
        await model.getStockActualQtyList();
        model.getStockActualQty(itemCode);
      },
      builder: (context, model, child) {
        var storageService = locator.get<StorageService>();
        var baseurl = storageService.apiUrl;
        return Scaffold(
          appBar: Common.commonAppBar('${model.product.itemName}', [], context),
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : SingleChildScrollView(
                  child: itemDetailWidget(model, context, baseurl),
                ),
        );
      },
    );
  }

  Widget itemDetailWidget(
      ItemsDetailViewModel model, BuildContext context, String baseurl) {
    return Column(
      children: [
        Card(
          elevation: 0,
          margin: EdgeInsets.symmetric(
              horizontal: Sizes.paddingWidget(context),
              vertical: Sizes.paddingWidget(context)),
          child: Column(
            children: [
              SizedBox(height: Sizes.paddingWidget(context)),
              //images
              model.product.image == null
                  ? ClipRRect(
                      borderRadius: Corners.xlBorder,
                      child: Image.asset(
                        Images.imageNotFound,
                        width: displayWidth(context),
                        fit: BoxFit.cover,
                      ),
                    )
                  : CustomCarousel(model: model),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
              ),
              // AttributesDropdown(model: model),
              ItemInfoMobile(model: model),
            ],
          ),
        ),
        ItemInfoWidget(model: model),
        SizedBox(height: Sizes.paddingWidget(context)),
        // for adding bottom padding to ios
        Padding(
          padding: EdgeInsets.only(
            bottom: Sizes.paddingWidget(context) * 1.5,
          ),
        ),
      ],
    );
  }
}

class Attributes extends StatelessWidget {
  final ItemsDetailViewModel model;
  const Attributes({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return model.productsFromVariants.isNotEmpty
        ? SizedBox(
            // padding: const EdgeInsets.only(left: Sizes.padding),
            height: displayWidth(context) < 600 ? 30 : 40,
            child: ListView.builder(
                itemCount: model.productsFromVariants.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: ((context, index) {
                  var item = model.productsFromVariants[index];
                  var attribute = '';
                  // item.attributes?.forEach((a) {
                  //   attribute += '${a.attribute}:${a.attributeValue}';
                  // });
                  // print(attribute);
                  return GestureDetector(
                    onTap: () async {
                      await model.setIsSelected(index);
                      // model.refresh();
                      model.updateQuantityController();
                    },
                    child: Container(
                      key: Key(attribute),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                          borderRadius: Corners.medBorder,
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          color: model.isSelected[index] == true
                              ? Theme.of(context).primaryColor
                              : ThemeModel().isDark
                                  ? Colors.black
                                  : Colors.white),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            attribute,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: model.isSelected[index] == true
                                      ? ThemeModel().isDark
                                          ? Colors.black
                                          : Colors.white
                                      : ThemeModel().isDark
                                          ? Colors.white
                                          : Colors.black,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                })),
          )
        : Container();
  }
}

class AttributesDropdown extends StatelessWidget {
  final ItemsDetailViewModel model;
  const AttributesDropdown({super.key, required this.model});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: displayWidth(context) < 600 ? 30 : 40,
      padding:
          EdgeInsets.symmetric(horizontal: Sizes.smallPaddingWidget(context)),
      decoration: BoxDecoration(
        color: CustomTheme.dropdownColor,
        borderRadius: Corners.xlBorder,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: model.dropdownAttributeSelected,
          onChanged: (value) {
            var index = model.attributeDropdownList.indexOf(value);
            model.setDropdownAttribute(value);
            model.setIsSelected(index);

            // model.refresh();
            model.updateQuantityController();
          },
          // hint: hint,
          // icon: icon,
          // iconDisabledColor: iconDisabledColor,
          // iconEnabledColor: iconEnabledColor,
          // iconSize: iconSize,
          items: model.attributeDropdownList
              .map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SubHeading extends StatelessWidget {
  final String title;
  final String text;
  const SubHeading({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.smallPadding),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: ThemeModel().isDark ? Colors.white : Colors.black,
                ),
          ),
          const Spacer(),
          Text(
            text,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class CustomCarousel extends StatelessWidget {
  final ItemsDetailViewModel model;
  const CustomCarousel({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    var images = model.files;
    return images.isEmpty
        ? Container()
        : Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
            child: Column(
              children: [
                CarouselSlider.builder(
                  key: const Key(TestCasesConstants.carousel),
                  options: CarouselOptions(
                    height: displayHeight(context) * 0.3,
                    viewportFraction: 1,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.scale,
                    onPageChanged: (index, reason) =>
                        model.pageChangedCallback(index),
                    scrollDirection: Axis.horizontal,
                  ),
                  itemCount: images.length,
                  itemBuilder:
                      (BuildContext context, int index, int pageViewIndex) =>
                          ClipRRect(
                    borderRadius: Corners.xlBorder,
                    child: CachedNetworkImage(
                      imageUrl:
                          '${locator.get<StorageService>().apiUrl}${images[index].fileUrl}',
                      httpHeaders: {
                        HttpHeaders.cookieHeader: DioHelper.cookies ?? ''
                      },
                      width: displayWidth(context),
                      height: displayHeight(context) * 0.4,
                      placeholder: (context, url) => const Icon(Icons.error),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                images == null
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: images.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () =>
                                model.controller.animateToPage(entry.key),
                            child: Container(
                              width: 12.0,
                              height: 12.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: Sizes.smallPadding,
                                  horizontal: Sizes.extraSmallPadding),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(model.current == entry.key
                                          ? 0.9
                                          : 0.4)),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          );
  }
}

class AddToCart extends StatelessWidget {
  final ItemsDetailViewModel model;
  final double height;
  const AddToCart({
    super.key,
    required this.model,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key(Strings.addToCart),
      height: height,
      width: 120,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(Theme.of(context).cardColor),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: Corners.xxlBorder,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary)),
            ),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                horizontal: Sizes.paddingWidget(context) * 1.5))),
        onPressed: model.product.hasVariants == 1
            ? () {
                showSnackBar('Can\'t add this item to cart as it is a template',
                    context);
              }
            : () async {
                var item = model.product;
                //TODO:Issue
                await add(
                    ItemsModel(
                        hasVariants: item.hasVariants,
                        imageUrl: item.image,
                        itemCode: item.itemCode,
                        itemDescription: item.description,
                        itemName: item.itemName,
                        quantity: 1,
                        variantOf: item.variantOf,
                        price: model.price),
                    model,
                    context);
                model.setItemInCartValue(true);
                model.updateQuantityController();
                await model.refresh();
                // model.setQuantity(1);
                // showAlert(model, context);
              },
        child: Text(Strings.add,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.secondary)),
      ),
    );
  }

  static Future add(
      ItemsModel item, ItemsDetailViewModel model, BuildContext context) async {
    var cartItem = Cart();
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    if (item.itemCode == model.product.itemCode) {
      var images = await locator
          .get<ItemsViewModel>()
          .getImages(item.itemCode, connectivityStatus);
      cartItem = Cart(
          id: item.itemCode,
          itemName: item.itemName,
          quantity: item.quantity,
          itemCode: item.itemCode,
          rate: item.price,
          imageUrl: images != [] ? images[0].fileUrl : item.imageUrl);

      if (locator
          .get<CartPageViewModel>()
          .existsInCart(locator.get<CartPageViewModel>().items, cartItem)) {
        for (var i = 0;
            i < locator.get<CartPageViewModel>().items.length;
            i++) {
          var item = locator.get<CartPageViewModel>().items[i];
          if (cartItem.itemCode == item.itemCode) {
            //Increment quantity
            await locator
                .get<CartPageViewModel>()
                .incrementQuantityOfItem(item, context);
          }
        }
      } else {
        await locator.get<CartPageViewModel>().add(cartItem, context);
      }
      var index = model.getIndexOfItemWrtCart();
      await locator.get<ItemsDetailViewModel>().setIndex(index);
    } else {
      var product = model.product;
      var images = await locator
          .get<ItemsViewModel>()
          .getImages(product.itemCode, connectivityStatus);
      cartItem = Cart(
          id: product.itemCode,
          itemName: product.itemName,
          quantity: item.quantity,
          itemCode: product.itemCode,
          rate: model.price,
          imageUrl: images != [] ? images[0].fileUrl : product.image);

      if (locator
          .get<CartPageViewModel>()
          .existsInCart(locator.get<CartPageViewModel>().items, cartItem)) {
        locator.get<CartPageViewModel>().items.forEach((item) {
          if (cartItem.itemCode == item.itemCode) {
            //Increment quantity
            locator
                .get<CartPageViewModel>()
                .incrementQuantityOfItem(item, context);
          }
        });
      } else {
        await locator.get<CartPageViewModel>().add(cartItem, context);
      }
      var index = model.getIndexOfItemWrtCart();
      await locator.get<ItemsDetailViewModel>().setIndex(index);
    }
    // update cart items after cart item is added and then initialize controller
    model.updateCartItems();
    await locator.get<CartPageViewModel>().initQuantityController();
    await model.refresh();
  }
}

class ItemInfoMobile extends StatelessWidget {
  final ItemsDetailViewModel model;
  const ItemInfoMobile({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.paddingWidget(context),
            vertical: Sizes.paddingWidget(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemInfoWidget1(model: model),
              SizedBox(height: Sizes.smallPaddingWidget(context)),
              model.attributeDropdownList.isEmpty
                  ? const SizedBox()
                  : AttributesDropdown(model: model),
            ],
          ),
        ),
      ],
    );
  }
}

class IncDecButton extends StatelessWidget {
  final ItemsDetailViewModel itemsmodel;
  const IncDecButton({super.key, required this.itemsmodel});

  @override
  Widget build(BuildContext context) {
    var iconSize = displayWidth(context) < 600 ? 24.0 : 32.0;
    var buttonDimension = displayWidth(context) < 600 ? 30.0 : 40.0;
    // int index = itemsmodel.index;
    return itemsmodel.stockActualQty == 0.0
        ? Text(
            'Out of Stock',
            style: TextStyle(
              color: CustomTheme.dangerColor,
            ),
          )
        : !itemsmodel.itemExistsInCart
            ? AddToCart(
                model: itemsmodel,
                height: displayWidth(context) < 600 ? 40 : 50)
            : Container(
                padding: EdgeInsets.symmetric(
                    vertical: Sizes.extraSmallPaddingWidget(context),
                    horizontal: Sizes.smallPaddingWidget(context) * 0.8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: Corners.xlBorder,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await remove(
                            itemsmodel.items[itemsmodel.index],
                            context,
                            itemsmodel.items[itemsmodel.index].quantity,
                            itemsmodel);
                        itemsmodel.updateQuantityController();
                        await itemsmodel.refresh();
                      },
                      child: SizedBox(
                        width: buttonDimension,
                        height: buttonDimension,
                        child: Icon(
                          Icons.remove,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: iconSize,
                          key: Key(
                              '${Strings.decrementButtonKey}${itemsmodel.items[itemsmodel.index].itemCode}'),
                        ),
                      ),
                    ),
                    SizedBox(width: Sizes.smallPaddingWidget(context)),
                    SizedBox(
                      width: displayWidth(context) < 600 ? 40 : 70,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: itemsmodel.quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: Sizes.extraSmallPaddingWidget(context)),
                          fillColor: Colors.transparent,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          ),
                        ),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary),
                        onChanged: (String value) async {
                          var cartPageViewModel =
                              locator.get<CartPageViewModel>();
                          // value empty
                          if (value.isEmpty) {
                          }
                          // not empty
                          else {
                            // item exists in cart set quantity
                            if (itemsmodel.itemInCart()) {
                              var cartItemObj = cartPageViewModel.items
                                  .firstWhere((e) =>
                                      e.itemCode ==
                                      itemsmodel.product.itemCode);
                              var index =
                                  cartPageViewModel.items.indexOf(cartItemObj);

                              if (int.parse(value) != 0) {
                                // await model.setQty(index, value);
                                cartPageViewModel.setQty(index, value, context);
                              }
                              // if set to 0 then remove from cart
                              if (int.parse(value) == 0) {
                                await cartPageViewModel.remove(index, context);
                              }
                            }
                            // item doesnt exist to cart add item
                            else {
                              var item = itemsmodel.product;
                              //TODO:Issue
                              var qty = int.parse(value);
                              await AddToCart.add(
                                  ItemsModel(
                                      hasVariants: item.hasVariants,
                                      imageUrl: item.image,
                                      itemCode: item.itemCode,
                                      itemDescription: item.description,
                                      itemName: item.itemName,
                                      quantity: qty,
                                      variantOf: item.variantOf,
                                      price: itemsmodel.price),
                                  itemsmodel,
                                  context);
                              itemsmodel.setItemInCartValue(true);
                              // itemsmodel.setQuantity(qty);
                            }
                            itemsmodel.updateCartItems();
                          }
                          itemsmodel.updateQuantityController();
                          await itemsmodel.refresh();
                        },
                      ),
                    ),
                    SizedBox(width: Sizes.smallPaddingWidget(context)),
                    GestureDetector(
                      onTap: () async {
                        // item exists in cart set quantity
                        if (itemsmodel.itemInCart()) {
                          await add(itemsmodel.items[itemsmodel.index], context,
                              itemsmodel);
                        }
                        // item doenst exists in cart add to cart
                        else {
                          // locator.get<CartPageViewModel>().add(cartItem);
                          var item = itemsmodel.product;
                          var price = await locator
                              .get<ItemsService>()
                              .getPrice(itemsmodel.product.itemCode!);
                          await AddToCart.add(
                              ItemsModel(
                                  hasVariants: item.hasVariants,
                                  imageUrl: item.image,
                                  itemCode: item.itemCode,
                                  itemDescription: item.description,
                                  itemName: item.itemName,
                                  quantity: 1,
                                  variantOf: item.variantOf,
                                  price: price),
                              itemsmodel,
                              context);
                          itemsmodel.setItemInCartValue(true);
                          itemsmodel.updateCartItems();
                        }
                        itemsmodel.updateQuantityController();
                        await itemsmodel.refresh();
                      },
                      child: SizedBox(
                        width: buttonDimension,
                        height: buttonDimension,
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: iconSize,
                          key: Key(
                              '${Strings.incrementButtonKey}${itemsmodel.items[itemsmodel.index].itemCode}'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
  }

  Future remove(Cart item, BuildContext context, int itemQuantity,
      ItemsDetailViewModel model) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = item;

    // when quantity reaches to 1 remove item from cart
    if (itemQuantity == 1) {
      // remove quantity from cart
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      await cartPageViewModel.remove(index, context);
      model.setItemInCartValue(false);
      //Removed item
    }
    // decrement quantity until quantity reaches to 1
    else {
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      await cartPageViewModel.decrement(index, context);
    }
    await model.updateCartItems();
    await cartPageViewModel.initQuantityController();
    itemsmodel.updateQuantityController();
    await model.refresh();
  }

  Future add(
      Cart item, BuildContext context, ItemsDetailViewModel model) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = item;

    if (itemsmodel.itemInCart()) {
      model.updateCartItems();
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = locator.get<CartPageViewModel>().items.indexOf(cartItemObj);
      //Increment quantity
      await locator.get<CartPageViewModel>().increment(index, context);
    } else {}
    await model.updateCartItems();
    await locator.get<CartPageViewModel>().initQuantityController();
    itemsmodel.updateQuantityController();
    await model.refresh();
  }
}

//Itemname,Itemcode,Itemgroup etc for mobile
class ItemInfoWidget1 extends StatelessWidget {
  final ItemsDetailViewModel model;
  const ItemInfoWidget1({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    var stockActualQtyStyle = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(model.product.itemName ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
        SizedBox(height: Sizes.smallPaddingWidget(context)),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKU : ${model.product.itemCode}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: CustomTheme.borderColor,
                        ),
                  ),
                  Text(
                    'Group : ${model.product.itemGroup}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    Formatter.formatter.format(model.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    model.stockActualQty == 0.0
                        ? ''
                        : 'Stock : ${model.stockActualQty}',
                    style: stockActualQtyStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: Sizes.smallPaddingWidget(context)),
            model.product.hasVariants == 1
                ? Container()
                : IncDecButton(itemsmodel: model),
          ],
        ),
      ],
    );
  }
}

//Description,Inventory,HSN etc
class ItemInfoWidget extends StatelessWidget {
  final ItemsDetailViewModel model;
  const ItemInfoWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: Corners.xlBorder,
            child: ExpansionTile(
              shape:
                  const RoundedRectangleBorder(borderRadius: Corners.xlBorder),
              tilePadding: EdgeInsets.symmetric(
                horizontal: Sizes.paddingWidget(context),
              ),
              title: Text(
                Strings.description,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // initiallyExpanded: true,
              onExpansionChanged: model.onExpansionChanged,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.paddingWidget(context),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          HtmlWidget(model.product.description ?? '',
                              textStyle:
                                  Theme.of(context).textTheme.titleSmall),
                        ],
                      ),
                      SubHeading(
                          title: 'Brand', text: model.product.brand ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Sizes.paddingWidget(context)),
          ClipRRect(
            borderRadius: Corners.xlBorder,
            child: ExpansionTile(
              shape:
                  const RoundedRectangleBorder(borderRadius: Corners.xlBorder),
              tilePadding: EdgeInsets.symmetric(
                horizontal: Sizes.paddingWidget(context),
              ),
              title: const Text(
                Strings.inventory,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // initiallyExpanded: true,
              onExpansionChanged: model.onExpansionChanged,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.paddingWidget(context),
                  ),
                  child: Column(
                    children: [
                      SubHeading(
                        title: 'Shell Life (Days)',
                        text: model.product.shelfLifeInDays != null
                            ? model.product.shelfLifeInDays.toString()
                            : 0.toString(),
                      ),
                      SubHeading(
                          title: 'Warranty Period',
                          text: model.product.warrantyPeriod != null
                              ? model.product.warrantyPeriod.toString()
                              : ''),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Sizes.paddingWidget(context)),
          Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Sizes.paddingWidget(context)),
                child: Column(
                  children: [
                    SubHeading(
                        title: 'HSN', text: model.product.gstHsnCode ?? ''),
                    SubHeading(
                        title: 'Unit Of Measure',
                        text: model.product.stockUom ?? ''),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
