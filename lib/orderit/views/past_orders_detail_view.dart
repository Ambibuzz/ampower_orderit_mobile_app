import 'package:google_fonts/google_fonts.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/sliver_common.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/past_orders_detail_viewmodel.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/util/helpers.dart';
import 'package:flutter/material.dart';
import 'image_widget_native.dart' if (dart.library.html) 'image_widget_web.dart'
    as image_widget;

class PastOrdersDetailView extends StatelessWidget {
  const PastOrdersDetailView({
    super.key,
    this.salesOrder,
  });
  final SalesOrder? salesOrder;

  @override
  Widget build(BuildContext context) {
    return BaseView<PastOrdersDetailViewModel>(
      onModelReady: (model) async {
        await model.getProducts(salesOrder);
      },
      builder: (context, model, child) {
        return BaseView<PastOrdersDetailViewModel>(
          builder: (context, model, child) {
            return WillPopScope(
              onWillPop: () async {
                // Set the result here when the back button is pressed
                locator.get<NavigationService>().pop(result: true);
                return false; // Prevents default back navigation
              },
              child: Scaffold(
                appBar: Common.commonAppBar(
                  'Order No. ${salesOrder?.name}',
                  [],
                  context,
                  sendResultBack: true,
                ),
                body: model.state == ViewState.busy
                    ? WidgetsFactoryList.circularProgressIndicator()
                    : pastOrdersDetail(model, context),
              ),
            );
          },
        );
      },
    );
  }

  Widget pastOrdersDetail(
      PastOrdersDetailViewModel model, BuildContext context) {
    var textStyle =
        Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16);

    return Stack(
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: Sizes.paddingWidget(context)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Sizes.paddingWidget(context)),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Sizes.paddingWidget(context),
                              vertical: Sizes.paddingWidget(context),
                            ),
                            child: Column(
                              children: [
                                Common.reusableRowWidget('Customer',
                                    salesOrder?.customer ?? '', context),
                                SizedBox(
                                    height: Sizes.smallPaddingWidget(context)),
                                Common.reusableRowWidget(
                                    'Transaction Date',
                                    defaultDateFormat(
                                        salesOrder!.transactiondate!),
                                    context),
                                SizedBox(
                                    height: Sizes.smallPaddingWidget(context)),
                                Common.reusableRowWidget(
                                    'Delivery Date',
                                    defaultDateFormat(
                                        salesOrder!.deliverydate!),
                                    context),
                                SizedBox(
                                    height: Sizes.smallPaddingWidget(context)),
                                Common.reusableRowWidget(
                                    'Total Quantity',
                                    (salesOrder?.totalqty ?? 0).toString(),
                                    context),
                                SizedBox(
                                    height: Sizes.smallPaddingWidget(context)),
                                Common.reusableRowWidget(
                                    'Grand Total',
                                    Formatter.formatter
                                        .format(salesOrder!.grandtotal),
                                    context,
                                    textStyle: GoogleFonts.inter(
                                        textStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 16,
                                    ))),
                                SizedBox(
                                    height: Sizes.smallPaddingWidget(context)),
                                Common.reusableRowWidget(
                                    'Status', salesOrder?.status, context),
                              ],
                            ),
                          ),
                        ),
                        verticalPaddingMedium(context),
                      ],
                    ),
                  ],
                ),
              ),
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                if (index == model.salesOrderItems.length - 1) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Corners.xxlRadius,
                      bottomRight: Corners.xxlRadius,
                    ),
                    child: cartItem(index, model, context),
                  );
                }
                return Column(
                  children: [
                    cartItem(index, model, context),
                    const Divider(
                      endIndent: 0,
                      height: 0,
                      indent: 0,
                      thickness: 1,
                    ),
                  ],
                );
              }, childCount: model.salesOrderItems.length)),
              CustomSliverSizedBox(
                height: Sizes.paddingWidget(context) * 1.5 * 3,
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: Sizes.paddingWidget(context)),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: createCart(model, context),
          ),
        ),
      ],
    );
  }

  Widget cartItem(
      int index, PastOrdersDetailViewModel model, BuildContext context) {
    var imageDimension = displayWidth(context) < 600 ? 38.0 : 62.0;
    var btnDimension = displayWidth(context) < 600 ? 28.0 : 52.0;
    var iconSize = displayWidth(context) < 600 ? 20.0 : 32.0;
    var item = model.salesOrderItems[index];
    var soItem = salesOrder?.salesOrderItems?[index];
    return Container(
        padding: EdgeInsets.symmetric(
          vertical: Sizes.smallPaddingWidget(context),
        ),
        color: Theme.of(context).cardColor,
        key: Key(item.itemName ?? ''),
        child: cartItemData(item, soItem, index, iconSize, imageDimension,
            btnDimension, context));
  }

  Widget cartItemRate(SalesOrderItems? item, int index, BuildContext context) {
    var textStyle = Theme.of(context).textTheme.titleSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price : ${Formatter.formatter.format((item?.rate ?? 0))} ',
          style: GoogleFonts.inter(textStyle: textStyle),
        ),
        Text(
          'Qty : ${item?.qty ?? 0} ',
          style: textStyle,
        ),
        Text(
          'Total : ${Formatter.formatter.format((item?.rate ?? 0) * (item?.qty ?? 0))} ',
          style: GoogleFonts.inter(
              textStyle: textStyle?.copyWith(
            fontWeight: FontWeight.bold,
          )),
        ),
      ],
    );
  }

  Widget cartItemData(
      Product? item,
      SalesOrderItems? soItem,
      int index,
      double iconSize,
      double imageDimension,
      double btnDimension,
      BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Sizes.smallPaddingWidget(context), vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: Sizes.extraSmallPaddingWidget(context)),
          item?.image == null || item?.image == ''
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
              : item?.image == null
                  ? Container()
                  : ClipRRect(
                      borderRadius: Corners.lgBorder,
                      child: image_widget.imageWidget(
                          '${locator.get<StorageService>().apiUrl}${item?.image}',
                          imageDimension,
                          imageDimension),
                    ),
          // cart item name
          Padding(
            padding: displayWidth(context) < 600
                ? EdgeInsets.only(left: Sizes.smallPaddingWidget(context))
                : EdgeInsets.symmetric(
                    horizontal: Sizes.paddingWidget(context)),
            child: SizedBox(
              width: displayWidth(context) < 600
                  ? displayWidth(context) * 0.37
                  : displayWidth(context) * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item?.itemName ?? '',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  cartItemRate(soItem, index, context),
                ],
              ),
            ),
          ),
          const Spacer(),
          const VerticalDivider(
            endIndent: 0,
            indent: 0,
            width: 0,
          ),
          SizedBox(
            width: Sizes.extraSmallPaddingWidget(context),
          ),
          displayWidth(context) < 600
              ? addToCartBtn(
                  item!, locator.get<PastOrdersDetailViewModel>(), context)
              : SizedBox(
                  width: 150,
                  child: addToCartBtn(
                      item!, locator.get<PastOrdersDetailViewModel>(), context),
                ),
        ],
      ),
    );
  }

  SizedBox verticalPaddingSmall(BuildContext context) {
    if (displayWidth(context) < 600) {
      return const SizedBox(height: 10);
    } else {
      return const SizedBox(height: 10 * 1.5);
    }
  }

  SizedBox verticalPaddingMedium(BuildContext context) {
    if (displayWidth(context) < 600) {
      return const SizedBox(height: 15);
    } else {
      return const SizedBox(height: 15 * 1.5);
    }
  }

  Widget addToCartBtn(
      Product item, PastOrdersDetailViewModel model, BuildContext context) {
    return addItemToCartReusableBtn(Strings.add, () async {
      await model.addItemToCart(item, context);
    }, context);
  }

  Widget addItemToCartReusableBtn(
      String text, void Function()? onPressed, BuildContext context) {
    return SizedBox(
      height: displayWidth(context) < 600 ? 32 : 50,
      width: 110,
      child: TextButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
                borderRadius: Corners.lgBorder,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                )),
          ),
          backgroundColor: WidgetStatePropertyAll(Theme.of(context).cardColor),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: Sizes.paddingWidget(context),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ),
    );
  }

  Widget createCart(PastOrdersDetailViewModel model, BuildContext context) {
    return Common.textButtonWithIcon(
      'Add to Cart',
      () async {
        await model.createCart(salesOrder, context);
        locator.get<NavigationService>().pop(result: true);
      },
      context,
    );
  }
}
