import 'package:carousel_slider/carousel_slider.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/common/widgets/empty_widget.dart';
import 'package:orderit/common/widgets/popup_menu_item.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/item_group.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/services/user_service.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/orderit/views/item_attributes_view.dart';
import 'package:orderit/orderit/views/items_detail_view.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'image_widget_native.dart' if (dart.library.html) 'image_widget_web.dart'
    as image_widget;

class ItemsView extends StatelessWidget {
  static final storageService = locator.get<StorageService>();
  final String? itemGroup;
  final String? item;
  final bool searchText;
  final String? type;
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'items_view_key');
  static const greenColor = Color(0xFF028431);

  ItemsView(
      {super.key,
      this.itemGroup,
      this.item,
      this.searchText = false,
      this.type});

  @override
  Widget build(BuildContext context) {
    var itemNameListStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
        );
    var itemNameCatalogStyle =
        Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            );
    var itemPriceListStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        );
    return BaseView<ItemsViewModel>(
      onModelReady: (model) async {
        // get user
        model.getUser();
        await model.itemGroupListWithoutReturn(context);
        var connectivityStatus =
            Provider.of<ConnectivityStatus>(context, listen: false);
        // item category code
        // fetch configurations
        await model.getFavorites();
        // cache doctypes
        await model.checkDoctypeCache();
        await model.cachePriceListAndItemPrice(7, context);
        await model.getStockActualQtyList();
        await model.getItemPrices();
        model.getConnectivityStatus(context);
        var isUserCustomer = locator.get<StorageService>().isUserCustomer;
        var user = locator.get<UserService>().getUser();
        // if user is customer get customer from email
        if (isUserCustomer) {
          await model.getCustomerFromEmail(user.email!);
          // set customer pricelist
          model.setPriceList();
        }
        // if user is not customer get customer from customer name which is passed from booking order on behalf of customer ie enter customer screen
        else {
          await model.getCustomerFromCustomerName(storageService.customer);
          // set customer pricelist
          model.setPriceList();
        }
        // if customer default pricelist is present
        if (model.customer.defaultPriceList != null) {
          // if (model.isUserCustomer && model.customer.defaultPriceList != null) {
          // set customer pricelist
          model.setPriceList();
        }
        // if customer default pricelist is not present show snackbar
        else {
          showSnackBar('Price List not found', context);
        }
        // store catalog data to a map for later using that data at another places i.e while placing sales order ,quotation etc
        await model.storeCatalogModelData();
        // setup cart items to cart page
        await locator.get<CartPageViewModel>().setCartItems();
        // init quantity controllers
        await locator.get<CartPageViewModel>().initQuantityController();
        await model.getCartItems();

        if (itemGroup != null) {
          model.setCategorySelected(itemGroup, '');
          await model.getItemGroupData(itemGroup!, context);
        } else if (itemGroup == null) {
        } else {
          //item is not null and search text true (search random text)
          if (item != null && searchText == true) {
            // if item == ''
            if (item == '') {
              await model.getAllItems();
            }

            // if type param = item_name
            if (type == Strings.itemNameType) {
              await model.getItemListFromItemName(item!, connectivityStatus);
            }
            // if type param = item_code
            if (type == Strings.itemCodeType) {
              await model.getItemListFromItemCode(item!, connectivityStatus);
            }
          }
          //specific item is clicked
          if (item != null && searchText == false) {
            // if type param = item_name
            if (type == Strings.itemNameType) {
              await model.getSpecificItemFromItemName(
                  item!, connectivityStatus);
            }
            // if type param = item_code
            if (type == Strings.itemCodeType) {
              await model.getSpecificItemFromItemCode(
                  item!, connectivityStatus);
            }
          }
        }
        await model.getProducts();
        // if item group is clicked then fetch tags associated with that item group
        if (itemGroup != null) {
          // await model.getTagsFromItemGroup(context, itemGroup);
          model.init();
        } else {
          // await model.getTags(context);
        }

        if (itemGroup != null) {
          // set catalogue view index
          if (model.itemList.isNotEmpty) {
            model.setCatalogItemIndex(0);
          }
        }
        // initialize quantity controller
        await model.initQuantityController();
        model.initCarouselData();
      },
      builder: (context, model, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: appBar(
              model.categorySelected ?? '',
              [
                GestureDetector(
                    onTap: () async {
                      var result = await locator
                          .get<NavigationService>()
                          .navigateTo(searchViewRoute,
                              arguments: itemsViewRoute);
                      if (result != null) {
                        var res = result as List;
                        if (res[0] == true) {
                          // for updating items controllers
                          model.updateCartItems();
                          // setup cart items to cart page
                          await locator.get<CartPageViewModel>().setCartItems();
                          // init quantity controllers
                          await locator
                              .get<CartPageViewModel>()
                              .initQuantityController();
                          await model.getCartItems();
                          // initialize quantity controller
                          await model.initQuantityController();
                        }
                      }
                    },
                    child: const Icon(Icons.search)),
                SizedBox(width: Sizes.smallPaddingWidget(context)),
                Common.profileReusableWidget(model.user, context),
                popUpMenu(model, context),
              ],
              context,
              model),
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : Stack(
                  children: [
                    model.itemGroups.isEmpty
                        ? EmptyWidget(
                            onRefresh: () async {
                              await model.reCacheData(model, context);
                            },
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth <= 600) {
                                return mobileView(
                                    model,
                                    itemNameListStyle,
                                    itemNameCatalogStyle,
                                    itemPriceListStyle,
                                    context);
                              } else {
                                return largeDevice(
                                    model,
                                    itemNameListStyle,
                                    itemNameCatalogStyle,
                                    itemPriceListStyle,
                                    context);
                              }
                            },
                          ),
                    OrderitWidgets.floatingCartButton(context, () {
                      model.refresh();
                      model.updateCartItems();
                      model.initQuantityController();
                    }),
                  ],
                ),
        );
      },
    );
  }

  Widget mobileView(
      ItemsViewModel model,
      TextStyle? itemNameListStyle,
      TextStyle? itemNameCatalogStyle,
      TextStyle? itemPriceListStyle,
      BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 22,
                  child: LeftPanel(
                    itemGroup: itemGroup,
                    model: model,
                  ),
                ),
                Expanded(
                  flex: 78,
                  child: Column(
                    children: [
                      // filterAndViewTypeIcon(
                      //     model, context),
                      Expanded(
                        flex: 25,
                        child: model.itemList.isEmpty
                            ? EmptyWidget(
                                onRefresh: () async {
                                  await model.reCacheData(model, context);
                                },
                              )
                            : model.viewType == ViewTypes.listView
                                ? ItemsList(
                                    model: model,
                                    width: 50,
                                    buttonDimension: 30,
                                    priceStyle: itemPriceListStyle,
                                    itemNameStyle: itemNameListStyle)
                                : model.viewType == ViewTypes.gridView
                                    ? FlexibleItemsGrid(
                                        model: model,
                                        crossAxisCount: 2,
                                        width: displayWidth(context) * 0.26,
                                        buttonDimension: 30,
                                        priceStyle: itemPriceListStyle,
                                        itemNameStyle: itemNameListStyle,
                                      )
                                    : model.viewType == ViewTypes.catalogueView
                                        ? CatalogueView(
                                            model: model,
                                            width: displayWidth(context) * 0.5,
                                            buttonDimension: 32,
                                            priceStyle: itemPriceListStyle,
                                            itemNameStyle: itemNameCatalogStyle,
                                          )
                                        : TableView(
                                            model: model,
                                            width: 32,
                                            buttonDimension: 30,
                                            priceStyle: itemPriceListStyle,
                                            itemNameStyle: itemNameListStyle,
                                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget largeDevice(
      ItemsViewModel model,
      TextStyle? itemNameListStyle,
      TextStyle? itemNameCatalogStyle,
      TextStyle? itemPriceListStyle,
      BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: LeftPanel(
                    itemGroup: itemGroup,
                    model: model,
                  ),
                ),
                Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 25,
                          child: model.itemList.isEmpty
                              ? EmptyWidget(
                                  onRefresh: () async {
                                    await model.reCacheData(model, context);
                                  },
                                )
                              : model.viewType == ViewTypes.listView
                                  ? ItemsList(
                                      model: model,
                                      width: 45,
                                      buttonDimension: 40,
                                      priceStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                      itemNameStyle: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(fontSize: 16))
                                  : model.viewType == ViewTypes.gridView
                                      ? FlexibleItemsGrid(
                                          model: model,
                                          crossAxisCount: 3,
                                          width: displayWidth(context) * 0.15,
                                          buttonDimension: 30,
                                          priceStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          itemNameStyle: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        )
                                      : model.viewType ==
                                              ViewTypes.catalogueView
                                          ? CatalogueView(
                                              model: model,
                                              width:
                                                  displayWidth(context) * 0.5,
                                              buttonDimension: 32,
                                              priceStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                              itemNameStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!,
                                            )
                                          : TableView(
                                              model: model,
                                              width: 32,
                                              buttonDimension: 30,
                                              priceStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                              itemNameStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  AppBar appBar(String? title, List<Widget>? actions, BuildContext context,
      ItemsViewModel model) {
    return AppBar(
      title: Row(
        children: [
          model.categorySelectedImage == null ||
                  model.categorySelectedImage == ''
              ? const SizedBox()
              : model.categorySelectedImage == null
                  ? Container()
                  : ClipRRect(
                      borderRadius: Corners.xlBorder,
                      child: image_widget.imageWidget(
                          '${locator.get<StorageService>().apiUrl}${model.categorySelectedImage!}',
                          40,
                          40),
                    ),
          SizedBox(
            width: Sizes.smallPaddingWidget(context),
          ),
          Expanded(
            child: Text(
              title ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
      leadingWidth: 35,
      leading: locator.get<StorageService>().isUserCustomer
          ? null
          : Navigator.of(context).canPop()
              ? Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          Images.backButtonIcon,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
      titleSpacing: Sizes.smallPaddingWidget(context) * 1.5,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Corners.xlRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF006CB5), // Starting color
              Color(0xFF002D4C) // ending color
            ],
          ),
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Corners.xlRadius,
        ),
      ),
    );
  }

  Widget verticalDivider() {
    return const VerticalDivider(
      endIndent: 0,
      indent: 0,
      thickness: 1,
      width: 0,
    );
  }

  Widget emptyWidget(String? text, BuildContext context) {
    return SizedBox(
      height: displayHeight(context) - kToolbarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text ?? Strings.noItemsFound,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget popUpMenu(ItemsViewModel model, BuildContext context) {
    return PopupMenuButton<ViewTypes>(
      // Callback that sets the selected popup menu item.
      color: Theme.of(context).colorScheme.onPrimary,
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert, size: Sizes.iconSizeWidget(context)),
      onSelected: (ViewTypes viewType) {
        if (viewType == ViewTypes.listView) {
          model.setViewType(ViewTypes.listView);
        }
        if (viewType == ViewTypes.gridView) {
          model.updateQuantityControllerCatalogViewText();
          model.setViewType(ViewTypes.gridView);
        }
        if (viewType == ViewTypes.tableView) {
          model.initQuantityController();
          model.setViewType(ViewTypes.tableView);
        }
        if (viewType == ViewTypes.catalogueView) {
          model.setViewType(ViewTypes.catalogueView);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ViewTypes>>[
        CustomPopUpMenu.viewTypeMenu(
            'Grid View', ViewTypes.gridView, Images.gridViewIcon, context),
        const PopupMenuDivider(),
        CustomPopUpMenu.viewTypeMenu(
            'Card View', ViewTypes.listView, Images.listViewIcon, context),
        const PopupMenuDivider(),
        CustomPopUpMenu.viewTypeMenu(
            'Table View', ViewTypes.tableView, Images.tableViewIcon, context),
        const PopupMenuDivider(),
        CustomPopUpMenu.viewTypeMenu('Catalogue View', ViewTypes.catalogueView,
            Images.catalogViewIcon, context),
      ],
    );
  }

  Widget viewTypes(ItemsViewModel model, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Sizes.extraSmallPaddingWidget(context),
          horizontal: Sizes.extraSmallPaddingWidget(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Filter(model: model),
          // SizedBox(width: Sizes.extraSmallPaddingWidget(context)),
          // displayWidth(context) < 600
          //     ? mobileViewTypes(model, context)
          //     :
          // tabletViewTypes(model, context),
          popUpMenu(model, context),
        ],
      ),
    );
  }
}

class CustomCarousel extends StatelessWidget {
  final ItemsModel item;
  final double? width;
  final double? height;
  const CustomCarousel({
    super.key,
    required this.item,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    var images = item.images;
    var itemsViewModel = locator.get<ItemsViewModel>();
    return (item.images == null || item.images?.isEmpty == true)
        ? Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              // borderRadius: Corners.lgBorder,
              image: DecorationImage(
                image: AssetImage(
                  Images.imageNotFound,
                ),
                fit: BoxFit.cover,
              ),
            ),
          )
        : Column(
            children: [
              CarouselSlider.builder(
                key: const Key(TestCasesConstants.carousel),
                options: CarouselOptions(
                  // initialPage: 0,
                  height: height,
                  // (constraints.maxWidth <= 350
                  //     ? 100
                  //     : ((constraints.maxWidth > 350 &&
                  //             constraints.maxWidth <= 550)
                  //         ? 150
                  //         : ((constraints.maxWidth > 550 &&
                  //                 constraints.maxWidth <= 1000)
                  //             ? 270
                  //             : 400))),
                  // aspectRatio: 16 / 9,
                  viewportFraction: 1,
                  // enableInfiniteScroll: true,
                  // reverse: false,
                  // autoPlay: false,
                  // autoPlayInterval: Duration(seconds: 3),
                  // autoPlayAnimationDuration: Duration(milliseconds: 800),
                  // autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  onPageChanged: (index, reason) =>
                      itemsViewModel.pageChangedCallback(
                          itemsViewModel.itemList.indexOf(item), index),
                  scrollDirection: Axis.horizontal,
                ),
                itemCount: images?.length,
                itemBuilder:
                    (BuildContext context, int index, int pageViewIndex) =>
                        ClipRRect(
                  borderRadius: Corners.lgBorder,
                  child: ClipRRect(
                    borderRadius: Corners.lgBorder,
                    child: image_widget.imageWidget(
                        '${locator.get<StorageService>().apiUrl}${images?[index].fileUrl}',
                        width,
                        height),
                  ),
                ),
              ),
              // logic for showing dots below image in carousel
              images == null
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        // print('Entry Key ${entry.key}');
                        // print(itemsViewModel.current.length);
                        return GestureDetector(
                          onTap: () => itemsViewModel
                              .controller[itemsViewModel.itemList.indexOf(item)]
                              .animateToPage(entry.key),
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: Sizes.smallPadding,
                                horizontal: Sizes.extraSmallPadding),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: itemsViewModel.current.isNotEmpty == true
                                  ? itemsViewModel.current[itemsViewModel
                                              .itemList
                                              .indexOf(item)] ==
                                          entry.key
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.grey
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          );
  }
}

class SelectVariantButton extends StatelessWidget {
  const SelectVariantButton(
      {super.key, required this.model, required this.item});
  final ItemsViewModel? model;
  final ItemsModel item;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: Key('Variant${item.itemCode}'),
      height: displayWidth(context) < 600 ? 35 : 40,
      width: displayWidth(context) < 600 ? 110 : 200,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xFFD9D9D9))),
        onPressed: () async {
          await showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            constraints: BoxConstraints(
              minWidth: displayWidth(context),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Corners.xxxlRadius,
                topRight: Corners.xxxlRadius,
              ),
            ),
            builder: (ctx) {
              return ItemAttributesView(
                item: item,
              );
            },
          );
        },
        child: Padding(
          padding:
              EdgeInsets.only(left: Sizes.extraSmallPaddingWidget(context)),
          child: Row(
            children: [
              Text(
                'Variant',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.grey[800]),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[800],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ItemsList extends StatelessWidget {
  final ItemsViewModel model;
  final double? width;
  final double? buttonDimension;
  final TextStyle? priceStyle;
  final TextStyle? itemNameStyle;
  const ItemsList({
    super.key,
    required this.model,
    this.width,
    this.buttonDimension,
    required this.priceStyle,
    required this.itemNameStyle,
  });

  @override
  Widget build(BuildContext context) {
    var stockActualQtyStyle = Theme.of(context).textTheme.titleSmall;
    return model.itemList.isEmpty == true
        ? EmptyWidget(
            onRefresh: () async {
              await model.reCacheData(model, context);
            },
          )
        : RefreshIndicator.adaptive(
            onRefresh: () async {
              await model.reCacheData(model, context);
            },
            child: ListView.builder(
              shrinkWrap: true,
              padding: displayWidth(context) < 600
                  ? EdgeInsets.symmetric(
                      vertical: Sizes.smallPaddingWidget(context))
                  : EdgeInsets.symmetric(
                      horizontal: Sizes.smallPaddingWidget(context),
                    ),
              itemCount: model.itemList.length,
              itemBuilder: (context, index) {
                var item = model.itemList[index];
                var isFavorite = model.isFavorite(item.itemCode!);
                var itemQuantity = 0;
                // set item quantity
                if (model.cartItems != null) {
                  for (var i = 0; i < model.cartItems!.length; i++) {
                    if (model.cartItems?[i].itemCode == item.itemCode) {
                      itemQuantity = model.cartItems![i].quantity;
                    }
                  }
                }
                var stockActualQty = model.getStockActualQty(item.itemCode);
                return displayWidth(context) < 600
                    ? listTileMobile(item, index, itemQuantity, isFavorite,
                        stockActualQty, stockActualQtyStyle, context)
                    : (displayWidth(context) >= 600 &&
                            displayWidth(context) <= 960)
                        ? listTileTablet(
                            item,
                            index,
                            itemQuantity,
                            isFavorite,
                            stockActualQty,
                            stockActualQtyStyle,
                            displayWidth(context) * 0.16,
                            context)
                        : (displayWidth(context) >= 600 &&
                                displayWidth(context) <= 960)
                            ? listTileTablet(
                                item,
                                index,
                                itemQuantity,
                                isFavorite,
                                stockActualQty,
                                stockActualQtyStyle,
                                displayWidth(context) * 0.16,
                                context)
                            : (displayWidth(context) > 960 &&
                                    displayWidth(context) <= 1280)
                                ? listTileTablet(
                                    item,
                                    index,
                                    itemQuantity,
                                    isFavorite,
                                    stockActualQty,
                                    stockActualQtyStyle,
                                    displayWidth(context) * 0.19,
                                    context)
                                : listTileTablet(
                                    item,
                                    index,
                                    itemQuantity,
                                    isFavorite,
                                    stockActualQty,
                                    stockActualQtyStyle,
                                    displayWidth(context) * 0.2,
                                    context);
              },
            ),
          );
  }

  Widget listTileMobile(
      ItemsModel item,
      int index,
      int itemQuantity,
      bool isFavorite,
      double? stockActualQty,
      TextStyle? stockActualQtyStyle,
      BuildContext context) {
    return //  item.price == 0
        //         ? Container()
        //         :
        GestureDetector(
      key: Key(item.itemCode ?? ''),
      onTap: () async {
        var result = await model.navigateToItemDetailPage(item, context);
        if (result == null) {
          await model.getCartItems();
          await model.initQuantityController();
        }
      },
      child:
          //  item.price == 0
          //     ? Container()
          //     :
          Stack(
        children: [
          Card(
            color: stockActualQty == 0.0
                ? CustomTheme.imageBorderColor
                : Theme.of(context).cardColor,
            margin: EdgeInsets.symmetric(
              horizontal: Sizes.smallPaddingWidget(context),
              vertical: Sizes.extraSmallPaddingWidget(context),
            ),
            shape: const RoundedRectangleBorder(borderRadius: Corners.xlBorder),
            child: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.smallPaddingWidget(context) * 1.5,
                    vertical: Sizes.smallPaddingWidget(context) * 1.5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: CustomTheme.imageBorderColor),
                              borderRadius: Corners.lgBorder,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  Sizes.extraSmallPaddingWidget(context) * 0.5,
                              vertical:
                                  Sizes.extraSmallPaddingWidget(context) * 0.5,
                            ),
                            child: ClipRRect(
                              borderRadius: Corners.lgBorder,
                              child: item.imageUrl == null
                                  ? ((item.images == null ||
                                          item.images?.isEmpty == true)
                                      ? Container(
                                          width: width,
                                          height: width,
                                          decoration: const BoxDecoration(
                                            borderRadius: Corners.lgBorder,
                                            image: DecorationImage(
                                              image: AssetImage(
                                                Images.imageNotFound,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : image_widget.imageWidget(
                                          '${locator.get<StorageService>().apiUrl}${item.images![0].fileUrl}',
                                          width,
                                          width))
                                  : image_widget.imageWidget(
                                      '${locator.get<StorageService>().apiUrl}${item.imageUrl}',
                                      width,
                                      width),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      Sizes.smallPaddingWidget(context)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.itemName}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: itemNameStyle,
                                  ),
                                  Text(
                                    'SKU : ${item.itemCode}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: CustomTheme.borderColor,
                                        ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: Sizes.smallPaddingWidget(context),
                                top: Sizes.extraSmallPaddingWidget(context)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Formatter.formatter.format(item.price),
                                  style: priceStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  stockActualQty == 0.0
                                      ? ''
                                      : 'Stock : $stockActualQty',
                                  style: stockActualQtyStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          item.hasVariants == 1
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      right: Sizes.extraSmallPaddingWidget(
                                          context)),
                                  child: SelectVariantButton(
                                    model: model,
                                    item: item,
                                  ),
                                )
                              : incDecBtn(
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: Sizes.extraSmallPaddingWidget(context) * 0.5,
            right: Sizes.extraSmallPaddingWidget(context) * 0.5,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => model.toggleFavorite(item.itemCode!, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget listTileTablet(
      ItemsModel item,
      int index,
      int itemQuantity,
      bool isFavorite,
      double? stockActualQty,
      TextStyle? stockActualQtyStyle,
      double widgetWidth,
      BuildContext context) {
    var normalTextStyle = Theme.of(context).textTheme.titleLarge;
    return //  item.price == 0
        //         ? Container()
        //         :
        GestureDetector(
      key: Key(item.itemCode ?? ''),
      onTap: () async {
        var result = await model.navigateToItemDetailPage(item, context);
        if (result == null) {
          await model.getCartItems();
          await model.initQuantityController();
        }
      },
      child:
          //  item.price == 0
          //     ? Container()
          //     :
          Stack(
        children: [
          Card(
            color: stockActualQty == 0.0
                ? CustomTheme.imageBorderColor
                : Theme.of(context).cardColor,
            margin: EdgeInsets.symmetric(
              vertical: Sizes.extraSmallPaddingWidget(context),
            ),
            shape: const RoundedRectangleBorder(borderRadius: Corners.xlBorder),
            child: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.smallPaddingWidget(context) * 0.5,
                    vertical: Sizes.paddingWidget(context),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: Sizes.cardPadding),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: CustomTheme.imageBorderColor),
                              borderRadius: Corners.lgBorder,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  Sizes.extraSmallPaddingWidget(context) * 0.5,
                              vertical:
                                  Sizes.extraSmallPaddingWidget(context) * 0.5,
                            ),
                            child: ClipRRect(
                              borderRadius: Corners.lgBorder,
                              child: item.imageUrl == null
                                  ? ((item.images == null ||
                                          item.images?.isEmpty == true)
                                      ? Container(
                                          width: width,
                                          height: width,
                                          decoration: const BoxDecoration(
                                            borderRadius: Corners.lgBorder,
                                            image: DecorationImage(
                                              image: AssetImage(
                                                Images.imageNotFound,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : image_widget.imageWidget(
                                          '${locator.get<StorageService>().apiUrl}${item.images![0].fileUrl}',
                                          width,
                                          width))
                                  : image_widget.imageWidget(
                                      '${locator.get<StorageService>().apiUrl}${item.imageUrl}',
                                      width,
                                      width),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: EdgeInsets.only(
                              left: Sizes.smallPaddingWidget(context),
                              right: Sizes.smallPaddingWidget(context),
                            ),
                            width: widgetWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.itemName}\n',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: itemNameStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: Sizes.extraSmallPadding),
                                  child: Text(
                                      Formatter.formatter.format(item.price),
                                      style: priceStyle),
                                ),
                                Text(
                                  stockActualQty == 0.0
                                      ? ''
                                      : 'Stock : $stockActualQty',
                                  style: stockActualQtyStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: widgetWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SKU : ${item.itemCode ?? ''}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: normalTextStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: Sizes.extraSmallPadding),
                                  child: Text('Group : ${item.itemGroup ?? ''}',
                                      style: normalTextStyle),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          item.hasVariants == 1
                              ? SelectVariantButton(
                                  model: model,
                                  item: item,
                                )
                              : const SizedBox(),
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
                                  stockActualQty: stockActualQty,
                                  index: index),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: Sizes.extraSmallPaddingWidget(context) * 0.5,
            right: Sizes.extraSmallPaddingWidget(context) * 0.5,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => model.toggleFavorite(item.itemCode!, context),
            ),
          ),
        ],
      ),
    );
  }
}

Widget incDecBtn(
    {required ItemsViewModel model,
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
    child: itemQuantity == 0
        ? SizedBox(
            height: displayWidth(context) < 600 ? 37 : 42,
            child: stockActualQty == 0.0
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
                        iconColor: Theme.of(context).colorScheme.onSecondary,
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
                            controller:
                                model.quantityControllerList[index].controller,
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
                                      .firstWhere(
                                          (e) => e.itemCode == item.itemCode);
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
                      key: Key('${Strings.incrementButtonKey}${item.itemCode}'),
                    ),
                  ],
                ),
              )
            : const SizedBox()),
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
    ItemsViewModel model, BuildContext context) async {
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
    ItemsModel item, ItemsViewModel model, BuildContext context) async {
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
  model.updateQuantityControllerCatalogViewText();
  await model.getCartItems();
  await model.refresh();
}

Widget incDecBtnCatalogView(
    {required ItemsViewModel model,
    required double? width,
    required double? buttonDimension,
    required TextStyle? priceStyle,
    required TextStyle? itemNameStyle,
    required ItemsModel item,
    required double? stockActualQty,
    required BuildContext context,
    required int index}) {
  var cartPageViewModel = locator.get<CartPageViewModel>();
  var iconSize = displayWidth(context) < 600 ? 24.0 : 32.0;
  return stockActualQty == 0.0
      ? Text(
          'Out of Stock',
          style: TextStyle(
            color: CustomTheme.dangerColor,
          ),
        )
      : !model.existsInCart(locator.get<CartPageViewModel>().items, item)
          ? SizedBox(
              height: displayWidth(context) < 600 ? 37 : 42,
              child: TextButton(
                key: Key('${Strings.addToCart}${item.itemCode}'),
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(Theme.of(context).cardColor),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: Corners.xxlBorder,
                      ),
                    )),
                onPressed: () async {
                  await model.add(item, context);
                  model.updateQuantityControllerCatalogViewText();
                  // update list and gridview controller
                  model.updateQuantityControllerText(index, 1.toString());
                  await model.refresh();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: displayWidth(context) < 600
                          ? Sizes.paddingWidget(context) * 1.5
                          : Sizes.paddingWidget(context) * 2),
                  child: Text(
                    Strings.add,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                  vertical: Sizes.extraSmallPaddingWidget(context),
                  horizontal: Sizes.smallPaddingWidget(context) * 0.8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: Corners.xxlBorder,
              ),
              child: Row(
                children: [
                  cartControllerButton(
                    iconColor: Theme.of(context).colorScheme.onSecondary,
                    iconSize: iconSize,
                    buttonDimension: buttonDimension,
                    icon: Icons.remove,
                    onPressed: () async {
                      await model.remove(
                          item,
                          context,
                          int.parse(
                              model.quantityControllerCatalogueView.text));
                      model.updateQuantityControllerCatalogViewText();
                      await model.refresh();
                    },
                    key: Key('${Strings.decrementButtonKey}${item.itemCode}'),
                  ),
                  incDecController(
                    controller: model.quantityControllerCatalogueView,
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
                      await model.refresh();
                    },
                    underlineColor: Theme.of(context).scaffoldBackgroundColor,
                    fillColor: Colors.transparent,
                    context: context,
                  ),
                  cartControllerButton(
                    iconColor: Theme.of(context).colorScheme.onSecondary,
                    iconSize: iconSize,
                    buttonDimension: buttonDimension,
                    icon: Icons.add,
                    onPressed: () async {
                      await model.add(item, context);

                      model.updateQuantityControllerCatalogViewText();
                      await model.refresh();
                    },
                    key: Key('${Strings.incrementButtonKey}${item.itemCode}'),
                  ),
                ],
              ),
            );
}

class TableView extends StatelessWidget {
  const TableView({
    super.key,
    required this.model,
    this.width,
    this.buttonDimension,
    this.priceStyle,
    this.itemNameStyle,
  });
  final ItemsViewModel model;
  final double? width;
  final double? buttonDimension;
  final TextStyle? priceStyle;
  final TextStyle? itemNameStyle;

  @override
  Widget build(BuildContext context) {
    var stockActualQtyStyle = Theme.of(context).textTheme.titleSmall;
    return model.itemList.isEmpty == true
        ? EmptyWidget(
            onRefresh: () async {
              await model.reCacheData(model, context);
            },
          )
        : RefreshIndicator.adaptive(
            onRefresh: () async {
              await model.reCacheData(model, context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: Sizes.smallPaddingWidget(context),
                horizontal: Sizes.extraSmallPaddingWidget(context),
              ),
              child: ClipRRect(
                borderRadius: Corners.xxlBorder,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: displayWidth(context) < 600
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: Sizes.smallPaddingWidget(context)),
                  itemCount: model.itemList.length,
                  itemBuilder: (context, index) {
                    var item = model.itemList[index];
                    var isFavorite = model.isFavorite(item.itemCode!);
                    var itemQuantity = 0;
                    // set item quantity
                    if (model.cartItems != null) {
                      for (var i = 0; i < model.cartItems!.length; i++) {
                        if (model.cartItems?[i].itemCode == item.itemCode) {
                          itemQuantity = model.cartItems![i].quantity;
                        }
                      }
                    }
                    var stockActualQty = model.getStockActualQty(item.itemCode);
                    if (index == 0) {
                      return tableView(item, index, itemQuantity, isFavorite,
                          stockActualQty, stockActualQtyStyle, context);
                    }
                    return Column(
                      children: [
                        const Divider(
                          endIndent: 0,
                          indent: 0,
                          height: 1,
                        ),
                        tableView(item, index, itemQuantity, isFavorite,
                            stockActualQty, stockActualQtyStyle, context)
                      ],
                    );
                  },
                ),
              ),
            ),
          );
  }

  Widget tableView(
      ItemsModel item,
      int index,
      int itemQuantity,
      bool isFavorite,
      double? stockActualQty,
      TextStyle? stockActualQtyStyle,
      BuildContext context) {
    return //  item.price == 0
        //         ? Container()
        //         :
        GestureDetector(
      key: Key(item.itemCode ?? ''),
      onTap: () async {
        var result = await model.navigateToItemDetailPage(item, context);
        if (result == null) {
          await model.getCartItems();
          await model.initQuantityController();
        }
      },
      child:
          //  item.price == 0
          //     ? Container()
          //     :
          Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: stockActualQty == 0.0
                  ? CustomTheme.imageBorderColor
                  : Theme.of(context).cardColor,
            ),
            child: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizes.smallPaddingWidget(context),
                    // vertical: Sizes.smallPaddingWidget(context) * 1.5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: CustomTheme.imageBorderColor),
                                borderRadius: Corners.lgBorder,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    Sizes.extraSmallPaddingWidget(context) *
                                        0.5,
                                vertical:
                                    Sizes.extraSmallPaddingWidget(context) *
                                        0.5,
                              ),
                              child: ClipRRect(
                                borderRadius: Corners.lgBorder,
                                child: item.imageUrl == null
                                    ? ((item.images == null ||
                                            item.images?.isEmpty == true)
                                        ? Container(
                                            width: width,
                                            height: width,
                                            decoration: const BoxDecoration(
                                              borderRadius: Corners.lgBorder,
                                              image: DecorationImage(
                                                image: AssetImage(
                                                  Images.imageNotFound,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : image_widget.imageWidget(
                                            '${locator.get<StorageService>().apiUrl}${item.images![0].fileUrl}',
                                            width,
                                            width))
                                    : image_widget.imageWidget(
                                        '${locator.get<StorageService>().apiUrl}${item.imageUrl}',
                                        width,
                                        width),
                              ),
                            ),
                            // CustomCarousel(item: item,width: width,height: width),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Sizes.smallPaddingWidget(context),
                                  vertical: Sizes.smallPaddingWidget(context),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.itemName}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    Text(
                                      'SKU : ${item.itemCode}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: CustomTheme.borderColor,
                                          ),
                                    ),
                                    Text(
                                      Formatter.formatter.format(item.price),
                                      style: priceStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      stockActualQty == 0.0
                                          ? ''
                                          : 'Stock : $stockActualQty',
                                      style: stockActualQtyStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            VerticalDivider(
                              endIndent: 0,
                              indent: 0,
                            ),
                            item.hasVariants == 1
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        right: Sizes.extraSmallPaddingWidget(
                                            context)),
                                    child: SelectVariantButton(
                                      model: model,
                                      item: item,
                                    ),
                                  )
                                : incDecBtn(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -Sizes.smallPaddingWidget(context),
            right: -Sizes.extraSmallPaddingWidget(context),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => model.toggleFavorite(item.itemCode!, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget tableHeader() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: CustomTheme.tableHeaderColor, borderRadius: Corners.xxlBorder),
      child: Row(
        children: [tableHeaderColumn('Item', 65), tableHeaderColumn('Qty', 35)],
      ),
    );
  }

  Widget tableHeaderColumn(String? text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text ?? '',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CatalogueView extends StatelessWidget {
  const CatalogueView(
      {super.key,
      required this.model,
      this.width,
      this.buttonDimension,
      this.priceStyle,
      this.itemNameStyle});
  final ItemsViewModel model;
  final double? width;
  final double? buttonDimension;
  final TextStyle? priceStyle;
  final TextStyle? itemNameStyle;

  @override
  Widget build(BuildContext context) {
    var stockActualQtyStyle = Theme.of(context).textTheme.titleSmall;
    return model.itemList.isEmpty
        ? EmptyWidget(
            onRefresh: () async {
              await model.reCacheData(model, context);
            },
          )
        : displayWidth(context) < 800
            ? catalogueTile(
                model.itemList[model.catalogItemIndex],
                model.catalogueItemQuantity,
                model.catalogItemIndex,
                stockActualQtyStyle,
                context,
              )
            : (displayWidth(context) >= 800 && displayWidth(context) <= 1280)
                ? catalogueTileTablet(
                    model.itemList[model.catalogItemIndex],
                    model.catalogueItemQuantity,
                    model.catalogItemIndex,
                    stockActualQtyStyle,
                    context,
                  )
                : catalogueTileLargeTablet(
                    model.itemList[model.catalogItemIndex],
                    model.catalogueItemQuantity,
                    model.catalogItemIndex,
                    stockActualQtyStyle,
                    context,
                  );
  }

  Widget catalogueTile(ItemsModel item, int itemQuantity, int index,
      TextStyle? stockActualQtyStyle, BuildContext context) {
    var stockActualQty = model.getStockActualQty(item.itemCode);
    var isFavorite = model.isFavorite(item.itemCode!);
    return //  item.price == 0
        //         ? Container()
        //         :
        GestureDetector(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: Sizes.smallPaddingWidget(context)),
                Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: Sizes.smallPaddingWidget(context),
                  ),
                  color: stockActualQty == 0.0
                      ? CustomTheme.imageBorderColor
                      : Theme.of(context).cardColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: Corners.xlBorder),
                  child: GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (details.primaryVelocity! > 0) {
                        // User swiped Right
                        if (model.catalogItemIndex != 0) {
                          model.setCatalogItemIndex(model.catalogItemIndex - 1);
                        }
                      } else if (details.primaryVelocity! < 0) {
                        // User swiped Left
                        if (model.catalogItemIndex !=
                            model.itemList.length - 1) {
                          model.setCatalogItemIndex(model.catalogItemIndex + 1);
                        }
                      }
                    },
                    child: Container(
                      key: Key(item.itemCode ?? ''),
                      decoration: const BoxDecoration(
                        borderRadius: Corners.medBorder,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.smallPaddingWidget(context) * 1.5,
                          vertical: Sizes.paddingWidget(context),
                        ),
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomCarousel(
                                  item: item,
                                  width: width,
                                  height: width,
                                ),
                              ],
                            ),
                            SizedBox(height: Sizes.smallPaddingWidget(context)),
                            catalogueItemInfoWidget(item, stockActualQty, index,
                                stockActualQtyStyle, context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Sizes.smallPaddingWidget(context),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Sizes.paddingWidget(context)),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (model.catalogItemIndex != 0) {
                            model.setCatalogItemIndex(
                                model.catalogItemIndex - 1);
                          }
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(
                                horizontal: Sizes.paddingWidget(context)),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                            model.catalogItemIndex != 0
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        label: const Text(
                          'Prev',
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${model.catalogItemIndex + 1} of ${model.itemList.length}',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: CustomTheme.borderColor,
                                ),
                      ),
                      const Spacer(),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (model.catalogItemIndex !=
                                model.itemList.length - 1) {
                              model.setCatalogItemIndex(
                                  model.catalogItemIndex + 1);
                            }
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              EdgeInsets.symmetric(
                                  horizontal: Sizes.paddingWidget(context)),
                            ),
                            backgroundColor: WidgetStateProperty.all(
                              model.catalogItemIndex ==
                                      model.itemList.length - 1
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          label: const Text(
                            'Next',
                          ),
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: Sizes.smallPaddingWidget(context),
              right: Sizes.smallPaddingWidget(context),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () => model.toggleFavorite(item.itemCode!, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget catalogueTileTablet(ItemsModel item, int itemQuantity, int index,
      TextStyle? stockActualQtyStyle, BuildContext context) {
    var stockActualQty = model.getStockActualQty(item.itemCode);
    var isFavorite = model.isFavorite(item.itemCode!);
    return //  item.price == 0
        //         ? Container()
        //         :
        GestureDetector(
      // onTap: () => model.navigateToItemDetailPage(item, context),
      child:
          //  item.price == 0
          //     ? Container()
          //     :
          Stack(
        children: [
          Wrap(
            children: [
              Column(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: Sizes.smallPaddingWidget(context),
                      vertical: Sizes.smallPaddingWidget(context),
                    ),
                    color: stockActualQty == 0.0
                        ? CustomTheme.imageBorderColor
                        : Theme.of(context).cardColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: Corners.xlBorder),
                    child: GestureDetector(
                      onHorizontalDragEnd: (DragEndDetails details) {
                        if (details.primaryVelocity! > 0) {
                          // User swiped Left
                          if (model.catalogItemIndex !=
                              model.itemList.length - 1) {
                            model.setCatalogItemIndex(
                                model.catalogItemIndex + 1);
                          }
                        } else if (details.primaryVelocity! < 0) {
                          // User swiped Right
                          if (model.catalogItemIndex != 0) {
                            model.setCatalogItemIndex(
                                model.catalogItemIndex - 1);
                          }
                        }
                      },
                      child: Container(
                        key: Key(item.itemName ?? ''),
                        decoration: const BoxDecoration(
                          borderRadius: Corners.medBorder,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Sizes.paddingWidget(context),
                            vertical: Sizes.paddingWidget(context),
                          ),
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomCarousel(
                                      item: item, width: width, height: width),
                                ],
                              ),
                              SizedBox(
                                  height: Sizes.smallPaddingWidget(context)),
                              catalogueItemInfoWidget(item, stockActualQty,
                                  index, stockActualQtyStyle, context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  catalogueViewTabletFooter(context),
                ],
              ),
            ],
          ),
          Positioned(
            top: Sizes.smallPaddingWidget(context),
            right: Sizes.smallPaddingWidget(context),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => model.toggleFavorite(item.itemCode!, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget catalogueTileLargeTablet(ItemsModel item, int itemQuantity, int index,
      TextStyle? stockActualQtyStyle, BuildContext context) {
    var stockActualQty = model.getStockActualQty(item.itemCode);
    var isFavorite = model.isFavorite(item.itemCode!);
    return //  item.price == 0
        //         ? Container()
        //         :
        GestureDetector(
      // onTap: () => model.navigateToItemDetailPage(item, context),
      child:
          //  item.price == 0
          //     ? Container()
          //     :
          Stack(
        children: [
          Wrap(
            children: [
              Column(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: Sizes.smallPaddingWidget(context),
                      vertical: Sizes.smallPaddingWidget(context),
                    ),
                    color: stockActualQty == 0.0
                        ? CustomTheme.imageBorderColor
                        : Theme.of(context).cardColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: Corners.xlBorder),
                    child: GestureDetector(
                      onHorizontalDragEnd: (DragEndDetails details) {
                        if (details.primaryVelocity! > 0) {
                          // User swiped Left
                          if (model.catalogItemIndex !=
                              model.itemList.length - 1) {
                            model.setCatalogItemIndex(
                                model.catalogItemIndex + 1);
                          }
                        } else if (details.primaryVelocity! < 0) {
                          // User swiped Right
                          if (model.catalogItemIndex != 0) {
                            model.setCatalogItemIndex(
                                model.catalogItemIndex - 1);
                          }
                        }
                      },
                      child: Container(
                        key: Key(item.itemName ?? ''),
                        decoration: const BoxDecoration(
                          borderRadius: Corners.medBorder,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Sizes.paddingWidget(context) * 1.5,
                            vertical: Sizes.paddingWidget(context) * 1.5,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    CustomCarousel(
                                        item: item,
                                        width: width,
                                        height: width),
                                  ],
                                ),
                              ),
                              SizedBox(width: Sizes.paddingWidget(context)),
                              Expanded(
                                flex: 1,
                                child: catalogueItemInfoWidget(
                                    item,
                                    stockActualQty,
                                    index,
                                    stockActualQtyStyle,
                                    context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  catalogueViewTabletFooter(context),
                ],
              ),
            ],
          ),
          Positioned(
            top: Sizes.smallPaddingWidget(context),
            right: Sizes.smallPaddingWidget(context),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => model.toggleFavorite(item.itemCode!, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget catalogueViewTabletFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
      height: 80,
      child: Row(
        children: [
          Expanded(
            flex: 25,
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (model.catalogItemIndex != 0) {
                    model.setCatalogItemIndex(model.catalogItemIndex - 1);
                  }
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(
                        horizontal: Sizes.paddingWidget(context)),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    model.catalogItemIndex != 0
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  ),
                ),
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text(
                  'Prev',
                ),
              ),
            ),
          ),
          SizedBox(width: Sizes.smallPaddingWidget(context)),
          Expanded(
            flex: 50,
            child: Column(
              children: [
                const SizedBox(height: 10),
                CupertinoSlider(
                  value: model.sliderValue,
                  divisions: model.itemList.length - 1,
                  min: 0,
                  max: (model.itemList.length - 1).toDouble(),
                  onChanged: (value) {
                    model.setCatalogItemIndex(value.toInt());
                    model.updateQuantityControllerCatalogViewText();
                  },
                ),
                Text(
                    '${(model.sliderValue + 1).toInt()} of ${model.itemList.length}'),
              ],
            ),
          ),
          SizedBox(width: Sizes.smallPaddingWidget(context)),
          Expanded(
            flex: 25,
            child: SizedBox(
              height: 50,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (model.catalogItemIndex != model.itemList.length - 1) {
                      model.setCatalogItemIndex(model.catalogItemIndex + 1);
                    }
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(
                          horizontal: Sizes.paddingWidget(context)),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                      model.catalogItemIndex == model.itemList.length - 1
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  label: const Text(
                    'Next',
                  ),
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget catalogueItemInfoWidget(ItemsModel item, double? stockActualQty,
      int index, TextStyle? stockActualQtyStyle, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${item.itemName}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: itemNameStyle,
        ),
        SizedBox(height: Sizes.smallPaddingWidget(context)),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SKU : ${item.itemCode}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: CustomTheme.borderColor,
                        ),
                  ),
                  Text(
                    Formatter.formatter.format(item.price),
                    style: priceStyle,
                  ),
                  Text(
                    stockActualQty == 0.0 ? '' : 'Stock : $stockActualQty',
                    style: stockActualQtyStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            item.hasVariants == 1
                ? SelectVariantButton(
                    model: model,
                    item: item,
                  )
                : incDecBtnCatalogView(
                    model: model,
                    width: width,
                    buttonDimension: buttonDimension,
                    priceStyle: priceStyle,
                    itemNameStyle: itemNameStyle,
                    item: item,
                    stockActualQty: stockActualQty,
                    context: context,
                    index: index),
          ],
        ),
        SizedBox(height: Sizes.smallPaddingWidget(context)),
        SizedBox(height: Sizes.paddingWidget(context)),
        Column(
          children: [
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Theme.of(context).dividerColor),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                collapsedBackgroundColor: stockActualQty == 0.0
                    ? CustomTheme.imageBorderColor
                    : Theme.of(context).cardColor,
                backgroundColor: stockActualQty == 0.0
                    ? CustomTheme.imageBorderColor
                    : Theme.of(context).cardColor,
                title: Text(
                  Strings.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                children: [
                  Row(
                    children: [
                      HtmlWidget(model.product.description ?? '',
                          textStyle: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                  SubHeading(title: 'Brand', text: model.product.brand ?? ''),
                ],
              ),
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              collapsedBackgroundColor: stockActualQty == 0.0
                  ? CustomTheme.imageBorderColor
                  : Theme.of(context).cardColor,
              backgroundColor: stockActualQty == 0.0
                  ? CustomTheme.imageBorderColor
                  : Theme.of(context).cardColor,
              title: Text(
                Strings.inventory,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              children: [
                SubHeading(
                    title: 'Shell Life (Days)',
                    text: model.product.shelfLifeInDays == null
                        ? ''
                        : model.product.shelfLifeInDays.toString()),
                SubHeading(
                    title: 'Warranty Period',
                    text: model.product.warrantyPeriod == null
                        ? ''
                        : model.product.warrantyPeriod.toString()),
                SubHeading(title: 'HSN', text: model.product.gstHsnCode ?? ''),
                SubHeading(
                    title: 'Unit Of Measure',
                    text: model.product.stockUom ?? ''),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class FlexibleItemsGrid extends StatelessWidget {
  final ItemsViewModel model;
  final int crossAxisCount;
  final double? width;
  final double? buttonDimension;
  final TextStyle? priceStyle;
  final TextStyle? itemNameStyle;
  const FlexibleItemsGrid({
    super.key,
    required this.model,
    required this.crossAxisCount,
    this.width,
    this.buttonDimension,
    this.priceStyle,
    this.itemNameStyle,
  });

  @override
  Widget build(BuildContext context) {
    var stockActualQtyStyle = Theme.of(context).textTheme.titleSmall;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: Sizes.extraSmallPaddingWidget(context),
          right: Sizes.extraSmallPaddingWidget(context),
          bottom: Sizes.smallPaddingWidget(context),
          top: Sizes.smallPaddingWidget(context),
        ),
        child: ClipRRect(
          borderRadius: Corners.xlBorder,
          child: LayoutGrid(
            // set some flexible track sizes based on the crossAxisCount
            columnSizes: [1.fr, 1.fr],
            // set all the row sizes to auto (self-sizing height)
            rowSizes: List<IntrinsicContentTrackSize>.generate(
                (model.itemList.length / 2).round(), (int index) => auto),
            rowGap: 1, // equivalent to mainAxisSpacing
            columnGap: 1, // equivalent to crossAxisSpacing
            // note: there's no childAspectRatio
            children:
                // render all the cards with *automatic child placement*
                model.itemList.map((e) {
              var item = e;
              var itemQuantity = 0;
              var isFavorite = model.isFavorite(item.itemCode!);
              // set item quantity
              if (model.cartItems != null) {
                for (var i = 0; i < model.cartItems!.length; i++) {
                  if (model.cartItems?[i].itemCode == item.itemCode) {
                    itemQuantity = model.cartItems![i].quantity;
                  }
                }
              }
              var stockActualQty = model.getStockActualQty(item.itemCode);
              return displayWidth(context) < 600
                  ? gridTile(
                      item,
                      itemQuantity,
                      isFavorite,
                      stockActualQty,
                      stockActualQtyStyle,
                      model.itemList.indexOf(item),
                      context)
                  : ((displayWidth(context) >= 600 &&
                          displayWidth(context) <= 1280)
                      ? gridTile(
                          item,
                          itemQuantity,
                          isFavorite,
                          stockActualQty,
                          stockActualQtyStyle,
                          model.itemList.indexOf(item),
                          context)
                      : gridTileLargeTablet(
                          item,
                          itemQuantity,
                          isFavorite,
                          stockActualQty,
                          stockActualQtyStyle,
                          model.itemList.indexOf(item),
                          displayWidth(context) * 0.13,
                          context));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget gridTile(
      ItemsModel item,
      int itemQuantity,
      bool isFavorite,
      double? stockActualQty,
      TextStyle? stockActualQtyStyle,
      int index,
      BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var result = await model.navigateToItemDetailPage(item, context);
        if (result == null) {
          await model.getCartItems();
          await model.initQuantityController();
        }
      },
      child: Container(
        key: Key(item.itemCode ?? ''),
        decoration: BoxDecoration(
          // border: Border.all(color: CustomTheme.tableBorderColor),
          color: stockActualQty == 0.0
              ? CustomTheme.imageBorderColor
              : Theme.of(context).cardColor,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.smallPaddingWidget(context),
          vertical: Sizes.paddingWidget(context),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CustomTheme.imageBorderColor),
                        borderRadius: Corners.xlBorder,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: Sizes.extraSmallPaddingWidget(context),
                        vertical: Sizes.extraSmallPaddingWidget(context),
                      ),
                      child: ClipRRect(
                        borderRadius: Corners.xlBorder,
                        child: item.imageUrl == null
                            ? ((item.images == null ||
                                    item.images?.isEmpty == true)
                                ? Image.asset(
                                    Images.imageNotFound,
                                    width: width,
                                    height: width,
                                  )
                                : image_widget.imageWidget(
                                    '${locator.get<StorageService>().apiUrl}${item.images![0].fileUrl}',
                                    width,
                                    width))
                            : image_widget.imageWidget(
                                '${locator.get<StorageService>().apiUrl}${item.imageUrl}',
                                width,
                                width),
                      ),
                    ),
                    SizedBox(height: displayWidth(context) < 600 ? 5 : 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.itemName}\n',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: itemNameStyle,
                        ),
                        const Divider(),
                        Text(
                          'SKU : ${item.itemCode}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: CustomTheme.borderColor,
                                  ),
                        ),
                        Text(
                          Formatter.formatter.format(item.price),
                          style: priceStyle,
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          stockActualQty == 0.0
                              ? ''
                              : 'Stock : $stockActualQty',
                          style: stockActualQtyStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Sizes.smallPaddingWidget(context)),
                item.hasVariants == 1
                    ? SelectVariantButton(
                        model: model,
                        item: item,
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
                            stockActualQty: stockActualQty,
                            index: index),
                  ],
                )
              ],
            ),
            Positioned(
              top: -Sizes.extraSmallPaddingWidget(context),
              right: -Sizes.extraSmallPaddingWidget(context),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () => model.toggleFavorite(item.itemCode!, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration myBoxDecoration(int index, int gridViewCrossAxisCount) {
    index++;
    return BoxDecoration(
      color: Colors.green,
      border: Border(
        left: BorderSide(
          //                   <--- left side
          color: index % gridViewCrossAxisCount != 0
              ? Colors.black12
              : Colors.transparent,
          width: 1.5,
        ),
        top: BorderSide(
          //                   <--- left side
          color: index > gridViewCrossAxisCount
              ? Colors.black12
              : Colors.transparent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget gridTileLargeTablet(
      ItemsModel item,
      int itemQuantity,
      bool isFavorite,
      double? stockActualQty,
      TextStyle? stockActualQtyStyle,
      int index,
      double imageWidth,
      BuildContext context) {
    var normalStyle = Theme.of(context).textTheme.titleMedium;
    return //  item.price == 0
        //         ? Container()
        //         :
        GestureDetector(
      onTap: () async {
        var result = await model.navigateToItemDetailPage(item, context);
        if (result == null) {
          await model.getCartItems();
          await model.initQuantityController();
        }
      },
      child: Card(
        margin: EdgeInsets.all(
          Sizes.extraSmallPaddingWidget(context),
        ),
        shape: const RoundedRectangleBorder(borderRadius: Corners.xlBorder),
        child: Container(
          key: Key(item.itemCode ?? ''),
          decoration: BoxDecoration(
            borderRadius: Corners.medBorder,
            color: stockActualQty == 0.0
                ? CustomTheme.imageBorderColor
                : Theme.of(context).cardColor,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.paddingWidget(context),
            vertical: Sizes.paddingWidget(context),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: imageWidth,
                        height: imageWidth,
                        child: CustomCarousel(
                            item: item,
                            width: imageWidth,
                            height: imageWidth -
                                Sizes.paddingWidget(context) * 1.2),
                      ),
                      SizedBox(height: Sizes.smallPaddingWidget(context)),
                      // item.hasVariants == 1
                      //     ? SelectVariantButton(
                      //         model: model,
                      //         item: item,
                      //       )
                      //     : const SizedBox(),
                    ],
                  ),
                  SizedBox(width: Sizes.paddingWidget(context)),
                  SizedBox(
                    width: displayWidth(context) * 0.17,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.itemName}\n',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: itemNameStyle,
                        ),
                        Text(
                          Formatter.formatter.format(item.price),
                          style: priceStyle,
                        ),
                        Text(
                          'SKU : ${item.itemCode ?? ''}',
                          style: normalStyle,
                        ),
                        Text(
                          'Item Group : ${item.itemGroup ?? ''}',
                          style: normalStyle,
                        ),
                        Text(
                          stockActualQty == 0.0
                              ? ''
                              : 'Stock : $stockActualQty',
                          style: stockActualQtyStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Sizes.smallPaddingWidget(context)),
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
                                stockActualQty: stockActualQty,
                                index: index),
                        item.hasVariants == 1
                            ? SelectVariantButton(
                                model: model,
                                item: item,
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: Sizes.extraSmallPaddingWidget(context) * 0.5,
                right: Sizes.extraSmallPaddingWidget(context) * 0.5,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () =>
                      model.toggleFavorite(item.itemCode!, context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftPanel extends StatelessWidget {
  const LeftPanel({
    super.key,
    required this.model,
    required this.itemGroup,
  });
  final ItemsViewModel model;
  final String? itemGroup;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Sizes.smallPaddingWidget(context),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Corners.xlRadius, bottomRight: Corners.xlRadius),
        child: CustomScrollView(
          slivers: [
            model.itemGroups.isEmpty == true
                ? const SliverToBoxAdapter()
                : ItemGroupsList(
                    itemGroups: model.itemGroups,
                    itemGroup: itemGroup,
                    model: model,
                  ),
          ],
        ),
      ),
    );
  }
}

class ItemGroupsList extends StatelessWidget {
  final List<ItemGroupModel> itemGroups;
  final String? itemGroup;
  final ItemsViewModel model;
  const ItemGroupsList(
      {super.key,
      required this.itemGroups,
      required this.itemGroup,
      required this.model});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: itemGroups.length,
      itemBuilder: (context, index) {
        return itemGroupListTile(context, index, itemGroups, model);
      },
    );
  }
}

Widget itemGroupListTile(BuildContext context, int index,
    List<ItemGroupModel> itemGroups, ItemsViewModel model) {
  var itemGroupModel = itemGroups[index];
  return GestureDetector(
    key: Key(itemGroupModel.name ?? ''),
    onTap: () async {
      model.setCatalogItemIndex(0);
      // fetch items list with item group
      await model.getItemGroupData(itemGroupModel.name!, context);
      await model.initQuantityController();
      model.setCategorySelected(itemGroupModel.name, itemGroupModel.image);
      model.initCarouselData();
    },
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      padding: EdgeInsets.symmetric(
        vertical: Sizes.smallPaddingWidget(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 4,
            height: 55,
            decoration: BoxDecoration(
                color: itemGroupModel.name == model.categorySelected
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Corners.xxxlRadius,
                  topRight: Corners.xxxlRadius,
                )),
          ),
          displayWidth(context) < 600
              ? Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      reusableImageWidget(itemGroupModel.image, 60, context),
                      SizedBox(
                        height: displayWidth(context) < 600
                            ? Sizes.verticalSmallPadding
                            : Sizes.verticalSmallPaddingLargeDevice,
                      ),
                      displayWidth(context) < 600
                          ? reusableListTileWidget(
                              itemGroupModel.name, model, context)
                          : SizedBox(
                              width: displayWidth(context) * 0.2,
                              child: reusableListTileWidget(
                                  itemGroupModel.name, model, context),
                            ),
                    ],
                  ),
                )
              : Expanded(
                  child: Row(
                    children: [
                      reusableImageWidget(itemGroupModel.image, 60, context),
                      SizedBox(
                        height: displayWidth(context) < 600
                            ? Sizes.verticalSmallPadding
                            : Sizes.verticalSmallPaddingLargeDevice,
                      ),
                      displayWidth(context) < 600
                          ? reusableListTileWidget(
                              itemGroupModel.name, model, context)
                          : SizedBox(
                              width: displayWidth(context) * 0.2,
                              child: reusableListTileWidget(
                                  itemGroupModel.name, model, context),
                            ),
                    ],
                  ),
                ),
        ],
      ),
    ),
  );
}

Widget reusableImageWidget(
    String? image, double? imageDimension, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: Sizes.extraSmallPaddingWidget(context) * 0.5,
    ),
    child: image == null || image == ''
        ? Container(
            width: imageDimension,
            height: imageDimension,
            decoration: const BoxDecoration(
              borderRadius: Corners.xlBorder,
              // boxShadow: boxShadow,
              image: DecorationImage(
                image: AssetImage(
                  Images.imageNotFound,
                ),
                fit: BoxFit.cover,
              ),
            ),
          )
        : image == null
            ? Container()
            : ClipRRect(
                borderRadius: Corners.xlBorder,
                child: image_widget.imageWidget(
                    '${locator.get<StorageService>().apiUrl}$image',
                    imageDimension,
                    imageDimension),
              ),
  );
}

Widget reusableListTileWidget(
    String? name, ItemsViewModel model, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: Sizes.extraSmallPaddingWidget(context)),
    child: Text(
      name ?? '',
      style: displayWidth(context) < 600
          ? Theme.of(context).textTheme.labelMedium?.copyWith(
              color: name == model.categorySelected
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurface)
          : Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: name == model.categorySelected
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSurface),
      overflow: TextOverflow.ellipsis,
      textAlign:
          displayWidth(context) < 700 ? TextAlign.center : TextAlign.start,
      maxLines: 2,
    ),
  );
}
