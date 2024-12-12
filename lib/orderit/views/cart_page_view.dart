import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/connectivity_status_strip.dart';
import 'package:orderit/common/widgets/empty_widget.dart';
import 'package:orderit/common/widgets/popup_menu_item.dart';
import 'package:orderit/common/widgets/sliver_common.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/item_category_bottom_nav_bar_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/custom_extensions.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'image_widget_native.dart' if (dart.library.html) 'image_widget_web.dart'
    as image_widget;

class CartPageView extends StatefulWidget {
  CartPageView({super.key});
  static final isUserCustomer = locator.get<StorageService>().isUserCustomer;

  @override
  State<CartPageView> createState() => _CartPageViewState();
}

class _CartPageViewState extends State<CartPageView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  Widget build(BuildContext context) {
    var connectivityStatus = Provider.of<ConnectivityStatus>(context);
    return BaseView<CartPageViewModel>(
      onModelReady: (model) async {
        tabController = TabController(length: 2, vsync: this);

        // setup cart items to cart page
        await model.setCartItems();
        // get item prices
        await model.getItemPrices();
        // clear selected items in cart
        model.init();
        // initialize quantity controller
        await model.initQuantityController();
        //get customer
        await model.getCustomer();
        // get total amount of items in cart
        model.getTotal();
      },
      onModelClose: (model) async {},
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            // Set the result here when the back button is pressed
            locator.get<NavigationService>().pop(result: true);
            return false; // Prevents default back navigation
          },
          child: Scaffold(
            appBar: Common.commonAppBar(
              'Your Cart',
              [
                customTextButtonWithIcon(
                  'Save Draft',
                  Images.saveAsDraftIcon,
                  Theme.of(context).colorScheme.secondary,
                  () async {
                    model.saveToDraft(context);
                  },
                  context,
                ),
                SizedBox(width: Sizes.smallPaddingWidget(context)),
                customTextButtonWithIcon(
                  'Clear Cart',
                  Images.clearCartIcon,
                  CustomTheme.dangerColor,
                  () async {
                    await model.showDialogToRemoveAllItems(context);
                  },
                  context,
                ),
                SizedBox(
                  width: Sizes.paddingWidget(context),
                ),
              ],
              context,
              sendResultBack: true,
            ),
            body: model.state == ViewState.busy
                ? WidgetsFactoryList.circularProgressIndicator()
                : Stack(
                    children: [
                      cartPageUi(model, connectivityStatus, context),
                      model.items.isNotEmpty == true
                          ? Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: totalStickyWidget(model, context))
                          : const SizedBox()
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget customTextButtonWithIcon(String? title, String icon, Color? color,
      void Function()? onPressed, BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: Corners.xxlBorder,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Sizes.extraSmallPaddingWidget(context),
            horizontal: Sizes.smallPaddingWidget(context),
          ),
          child: Row(
            children: [
              Text(
                title ?? '',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              SizedBox(
                width: Sizes.extraSmallPaddingWidget(context),
              ),
              Image.asset(
                icon,
                width: 18,
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget deleteSelectedItems(CartPageViewModel model, context) {
    return SizedBox(
      height: displayWidth(context) < 600 ? 30 : 40,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextButton.icon(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                  borderRadius: Corners.xlBorder,
                  side: BorderSide(color: Color(0xFFBE2527))),
            ),
            iconSize:
                WidgetStateProperty.all(displayWidth(context) < 600 ? 20 : 24),
            backgroundColor: WidgetStateProperty.all(
                Theme.of(context).scaffoldBackgroundColor),
          ),
          onPressed: () async {
            model.removeSelectedItems(context);
          },
          icon: const Icon(
            Icons.delete,
            color: Color(0xFFBE2527),
          ),
          label: Text(
            'Remove',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFBE2527),
                ),
          ),
        ),
      ),
    );
  }

  Widget emptyWidget(CartPageViewModel model, BuildContext context) {
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: SizedBox(
          height: displayHeight(context) * 0.85,
          child: OrderitWidgets.emptyCartWidget(
            'Your Cart is Empty!',
            'Let’s start adding items to fill it up which you can order later!',
            'Let’s Shop!',
            () {
              Navigator.of(context).pop();
              locator.get<ItemCategoryBottomNavBarViewModel>().setIndex(0);
              locator.get<ItemsViewModel>().updateCartItems();
              locator.get<ItemsViewModel>().initQuantityController();
            },
            context,
          ),
        ),
      ),
    ]);
  }

  Widget cartPageUi(CartPageViewModel model,
      ConnectivityStatus connectivityStatus, BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConnectivityStatusStrip.strip(connectivityStatus, context),
        ),
        model.items.isEmpty
            ?
            // const EmptyWidget()
            emptyWidget(model, context)
            : cartItemsSliver(model.items, model),
      ],
    );
  }

  Widget cartItemsSliver(List<Cart> items, CartPageViewModel model) {
    var imageDimension = displayWidth(context) < 600 ? 35.0 : 60.0;
    var btnDimension = displayWidth(context) < 600 ? 23.0 : 48.0;
    var iconSize = displayWidth(context) < 600 ? 20.0 : 32.0;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Sizes.smallPaddingWidget(context)),
      child: CustomScrollView(
        slivers: [
          CustomSliverSizedBox(
            child: SizedBox(height: Sizes.paddingWidget(context)),
          ),
          CustomSliverSizedBox(
            child: customerNameReusableWidget(
              context,
            ),
          ),
          items.isNotEmpty == true
              ? CustomSliverSizedBox(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: Sizes.smallPaddingWidget(context)),
                    child: GestureDetector(
                      onTap: () {
                        model.toggleSelectAll();
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: Sizes.smallPaddingWidget(context),
                          ),
                          Column(
                            children: [
                              model.selectAll
                                  ? const Icon(Icons.check_box, size: 20)
                                  : const Icon(Icons.check_box_outline_blank,
                                      size: 20),
                              Text(
                                'All',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: Sizes.paddingWidget(context),
                          ),
                          Text(
                            '${model.selectedItems.length}/${model.items.length} Selected',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          model.selectedItems.isNotEmpty
                              ? _CartPageViewState()
                                  .deleteSelectedItems(model, context)
                              : const SizedBox(),
                          SizedBox(width: Sizes.smallPaddingWidget(context)),
                        ],
                      ),
                    ),
                  ),
                )
              : const CustomSliverSizedBox(child: SizedBox()),
          items.isEmpty
              ? const CustomSliverSizedBox(child: SizedBox())
              : model.quantityControllerList.isEmpty
                  ? const CustomSliverSizedBox(child: SizedBox())
                  : SliverList(
                      delegate: SliverChildListDelegate(items.map(
                        (item) {
                          var index = items.indexOf(item);
                          var isSelected = model.selectedItems.contains(index);
                          return GestureDetector(
                            onTap: () {
                              model.toggleSelected(isSelected, index);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      Sizes.smallPaddingWidget(context)),
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        Sizes.extraSmallPaddingWidget(context),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: index == 0
                                          ? Corners.xlRadius
                                          : Radius.zero,
                                      topRight: index == 0
                                          ? Corners.xlRadius
                                          : Radius.zero,
                                      bottomLeft: index == items.length - 1
                                          ? Corners.xlRadius
                                          : Radius.zero,
                                      bottomRight: index == items.length - 1
                                          ? Corners.xlRadius
                                          : Radius.zero,
                                    ),
                                    color: isSelected
                                        ? Colors.blue[200]
                                        : Theme.of(context).colorScheme.surface,
                                  ),
                                  child: cartItem(
                                      item,
                                      index,
                                      imageDimension,
                                      btnDimension,
                                      iconSize,
                                      isSelected,
                                      model,
                                      context)),
                            ),
                          );
                        },
                      ).toList()),
                    ),
          verticalPaddingMedium(context),
          CustomSliverSizedBox(
            child: SizedBox(height: Sizes.paddingWidget(context) * 5),
          ),
        ],
      ),
    );
  }

  Widget verticalPaddingSmall(BuildContext context) {
    return CustomSliverSizedBox(
      child: SizedBox(
        height: Sizes.smallPaddingWidget(context),
      ),
    );
  }

  Widget verticalPaddingMedium(BuildContext context) {
    return CustomSliverSizedBox(
      child: SizedBox(
        height: Sizes.paddingWidget(context),
      ),
    );
  }

  Widget needSomethingElse(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(
        horizontal: Sizes.smallPaddingWidget(context),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.smallPaddingWidget(context),
          vertical: Sizes.paddingWidget(context),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Need something else?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                locator.get<ItemCategoryBottomNavBarViewModel>().setIndex(0);
              },
              child: Text(
                ' Add more items',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.secondary,
                    )
                    .underlined(distance: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customerNameReusableWidget(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: Sizes.smallPaddingWidget(context)),
      child: Container(
        height: displayWidth(context) < 600 ? 40 : 50,
        decoration: BoxDecoration(
          borderRadius: Corners.xlBorder,
          color: Theme.of(context).cardColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Sizes.smallPaddingWidget(context)),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Customer : ${locator.get<StorageService>().customerSelected}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              // allow switching of customer only when user is not customer
              locator.get<StorageService>().isUserCustomer
                  ? const SizedBox()
                  : GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Change Customer',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  Theme.of(context).colorScheme.secondary,
                            )
                            .underlined(distance: 2),
                      ),
                    ),
              SizedBox(
                width: Sizes.extraSmallPaddingWidget(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cartItem(
      Cart item,
      int index,
      double imageDimension,
      double btnDimension,
      double iconSize,
      bool isSelected,
      CartPageViewModel model,
      BuildContext context) {
    return cartItemData(item, index, iconSize, imageDimension, btnDimension,
        isSelected, model, context);
  }

  Widget cartItemRate(Cart item, int index, BuildContext context) {
    var textStyle = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${Formatter.formatter.format((item.rate ?? 0))} ',
          style: textStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // Text(
        //   'Total : ${Formatter.formatter.format(((item.rate ?? 0) * items[index].quantity))} ',
        //   style: textStyle.copyWith(
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
      ],
    );
  }

  Widget cartItemRateTablet(
      Cart item, int index, CartPageViewModel model, BuildContext context) {
    var textStyle = Theme.of(context).textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price : ${Formatter.formatter.format((item.rate ?? 0))} ',
          style: textStyle,
        ),
        Text(
          'Total : ${Formatter.formatter.format((item.rate ?? 0) * model.items[index].quantity)} ',
          style: textStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget cartItemData(
      Cart item,
      int index,
      double iconSize,
      double imageDimension,
      double btnDimension,
      bool isSelected,
      CartPageViewModel model,
      BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.smallPaddingWidget(context),
        vertical: Sizes.smallPaddingWidget(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isSelected
              ? const Icon(Icons.check_box, size: 20)
              : const Icon(Icons.check_box_outline_blank, size: 20),
          const SizedBox(width: Sizes.extraSmallPadding),
          ClipRRect(
            borderRadius: Corners.lgBorder,
            child: item.imageUrl == null || item.imageUrl == ''
                ? Container(
                    width: imageDimension,
                    height: imageDimension,
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
                        imageDimension,
                        imageDimension),
          ),
          // cart item name
          Padding(
            padding: displayWidth(context) < 600
                ? EdgeInsets.only(left: Sizes.smallPaddingWidget(context))
                : EdgeInsets.symmetric(
                    horizontal: Sizes.paddingWidget(context),
                  ),
            child: SizedBox(
              width: displayWidth(context) < 600
                  ? displayWidth(context) * 0.38
                  : displayWidth(context) * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${model.items[index].itemName}',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  cartItemRate(item, index, context),
                ],
              ),
            ),
          ),
          const Spacer(),
          incDecBtn(index, btnDimension, iconSize, model, context),
        ],
      ),
    );
  }

  Widget removeCartItem(
      int index, CartPageViewModel model, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: displayWidth(context) < 600
              ? Sizes.extraSmallPaddingWidget(context)
              : 0,
          right: Sizes.extraSmallPaddingWidget(context)),
      child: GestureDetector(
        onTap: () async {
          await model.showDialogToRemoveSingleItem(index, context);
        },
        child: Icon(Icons.close, size: displayWidth(context) < 600 ? 28 : 40),
      ),
    );
  }

  Widget incDecBtn(int index, double btnDimension, double iconSize,
      CartPageViewModel model, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: Sizes.extraSmallPaddingWidget(context),
          horizontal: Sizes.smallPaddingWidget(context) * 0.8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: Corners.xxlBorder,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              if (model.items[index].quantity == 1) {
                await model.showDialogToRemoveSingleItem(index, context);
              } else {
                await model.decrement(index, context);
              }
            },
            child: SizedBox(
              width: btnDimension,
              height: btnDimension,
              child: Icon(
                Icons.remove,
                color: Theme.of(context).colorScheme.secondary,
                size: iconSize,
              ),
            ),
          ),
          //TextField
          SizedBox(
            width: displayWidth(context) < 600 ? 40 : 60,
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
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary),
              onChanged: (String value) async {
                if (value.isEmpty) {
                  // do nothing
                } else {
                  if (value == '0') {
                    await model.showDialogToRemoveSingleItem(index, context);
                  } else {
                    model.setQty(index, value, context);
                  }
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () async {
              await model.increment(index, context);
            },
            child: SizedBox(
              width: btnDimension,
              height: btnDimension,
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.secondary,
                size: iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget totalStickyWidget(CartPageViewModel model, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(
        topLeft: Corners.xxlRadius,
        topRight: Corners.xxlRadius,
      ),
      color: Theme.of(context).cardColor,
    ),
    padding: EdgeInsets.all(Sizes.paddingWidget(context)),
    child: Column(
      children: [
        Row(
          children: [
            // const CartPageView().clearCart(model, context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF1E1E1E),
                      ),
                ),
                SizedBox(
                  height: Sizes.smallPaddingWidget(context),
                ),
                Text(
                  Formatter.formatter.format(model.total),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Spacer(),
            PostSalesOrder(
                items: model.items,
                model: model,
                width: displayWidth(context) * 0.48,
                isUserOnline: true),
          ],
        ),
      ],
    ),
  );
}

class PostSalesOrder extends StatelessWidget {
  final List<Cart> items;
  final CartPageViewModel model;
  final double? width;
  final bool isUserOnline;
  const PostSalesOrder(
      {super.key,
      required this.items,
      required this.model,
      this.width,
      required this.isUserOnline});

  @override
  Widget build(BuildContext context) {
    return Common.textButtonWithIcon(
      'Place Order',
      () async {
        if (isUserOnline && model.items.isNotEmpty) {
          await model.postSalesOrder(items, context);
        } else {
          await model.showSavetoDraftDialog(model, context);
        }
      },
      context,
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.extraSmallPaddingWidget(context),
        vertical: Sizes.smallPaddingWidget(context),
      ),
    );
  }
}
