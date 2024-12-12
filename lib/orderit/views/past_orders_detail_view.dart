import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
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
            return Scaffold(
              appBar: Common.commonAppBar(salesOrder?.name ?? '', [], context),
              body: model.state == ViewState.busy
                  ? WidgetsFactoryList.circularProgressIndicator()
                  : pastOrdersDetail(model, context),
            );
          },
        );
      },
    );
  }

  Widget pastOrdersDetail(
      PastOrdersDetailViewModel model, BuildContext context) {
    var textStyle = Theme.of(context).textTheme.titleSmall;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Sizes.paddingWidget(context)),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salesOrder?.customer ?? '',
                      style: textStyle,
                    ),
                    verticalPaddingSmall(context),
                    Text(
                        'Transaction Date : ${defaultDateFormat(salesOrder!.transactiondate!)}',
                        style: textStyle),
                    verticalPaddingSmall(context),
                    Text(
                        'Delivery Date : ${defaultDateFormat(salesOrder!.deliverydate!)}',
                        style: textStyle),
                    verticalPaddingSmall(context),
                    Text(
                      'Total Quantity : ${salesOrder?.totalqty}',
                      style: textStyle,
                    ),
                    verticalPaddingSmall(context),
                    Text(
                        'Grand Total ${Formatter.formatter.format(salesOrder!.grandtotal)}',
                        style: textStyle),
                    verticalPaddingSmall(context),
                    Text(
                      'Status : ${salesOrder?.status}',
                      style: textStyle,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                verticalPaddingMedium(context),
                Card(
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: Corners.xxlBorder),
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      tableHeader(context),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: model.salesOrderItems.length,
                        itemBuilder: (context, index) {
                          if (index == model.salesOrderItems.length - 1) {
                            return cartItem(index, model, context);
                          }
                          // return cartItem(index, model, context);
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
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            verticalPaddingMedium(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createCart(model, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tableHeader(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: CustomTheme.tableHeaderColor, borderRadius: Corners.xxlBorder),
      child: Row(
        children: [
          tableHeaderColumn('Item', 65),
          tableHeaderColumn('Qty', displayWidth(context) < 600 ? 35 : 25),
        ],
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

  Widget cartItem(
      int index, PastOrdersDetailViewModel model, BuildContext context) {
    var imageDimension = displayWidth(context) < 600 ? 38.0 : 62.0;
    var btnDimension = displayWidth(context) < 600 ? 28.0 : 52.0;
    var iconSize = displayWidth(context) < 600 ? 20.0 : 32.0;
    var item = model.salesOrderItems[index];
    var soItem = salesOrder?.salesOrderItems?[index];
    return SizedBox(
        height: 90,
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
          style: textStyle,
        ),
        Text(
          'Total : ${Formatter.formatter.format((item?.rate ?? 0) * (item?.qty ?? 0))} ',
          style: textStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
          horizontal: Sizes.extraSmallPaddingWidget(context), vertical: 0),
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
                borderRadius: Corners.xxlBorder,
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
      },
      context,
    );
  }
}
