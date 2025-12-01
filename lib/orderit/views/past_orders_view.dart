import 'package:google_fonts/google_fonts.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/common/widgets/empty_widget.dart';
import 'package:orderit/common/widgets/stacked_images.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/filters/past_orders_filter_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/past_orders_viewmodel.dart';
import 'package:orderit/orderit/views/filters/past_orders_filter_view.dart';
import 'package:orderit/orderit/views/past_orders_detail_view.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PastOrdersView extends StatelessWidget {
  const PastOrdersView({super.key});
  static final isUserCustomer = locator.get<StorageService>().isUserCustomer;

  @override
  Widget build(BuildContext context) {
    return BaseView<PastOrdersViewModel>(
      onModelReady: (model) async {
        await model.getPastOrders(context, []);
        await model.getItems(context);
        await model.getProducts();
        model.getSalesOrderItemsImages();
        locator.get<PastOrdersFilterViewModel>().clearData();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: Common.commonAppBar(
              'Past Orders',
              [
                GestureDetector(
                    onTap: () async {
                      var result = await openPastOrderFilter(context);
                      var filters = result as List;
                      if (result[0] is! List) {
                        model.setStatusSO(result[0]);
                        await model.getPastOrders(context, []);
                      } else {
                        var filters = result[0] as List;
                        await model.getPastOrders(context, filters);
                      }
                    },
                    child: const Icon(Icons.filter_alt)),
                SizedBox(
                  width: Sizes.smallPaddingWidget(context),
                ),
              ],
              context),
          body: SafeArea(
            child: model.state == ViewState.busy
                ? WidgetsFactoryList.circularProgressIndicator()
                : Stack(
                    children: [
                      PastOrderListView(model: model),
                      OrderitWidgets.floatingCartButton(context, () {
                        model.refresh();
                      }),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<dynamic> openPastOrderFilter(BuildContext context) async {
    return await showModalBottomSheet(
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
        return const PastOrdersFilterView();
      },
    );
  }
}

class PastOrderListView extends StatelessWidget {
  const PastOrderListView({super.key, required this.model});
  final PastOrdersViewModel model;

  @override
  Widget build(BuildContext context) {
    if (model.isSalesOrderLoading) {
      return Skeletonizer(
        enabled: model.isSalesOrderLoading,
        child: ListView.builder(
          itemCount: model.salesOrderList.length,
          padding: EdgeInsets.symmetric(
            vertical: Sizes.paddingWidget(context),
            horizontal: Sizes.paddingWidget(context),
          ),
          itemBuilder: (context, index) {
            var pastOrder = model.salesOrderList[index];
            return pastOrderListTile(pastOrder, context);
          },
        ),
      );
    } else if (model.salesOrderList.isEmpty) {
      return const EmptyWidget();
    } else {
      return Skeletonizer(
        enabled: model.isSalesOrderLoading,
        child: ListView.builder(
          itemCount: model.salesOrderList.length,
          padding: EdgeInsets.symmetric(
            vertical: Sizes.paddingWidget(context),
            horizontal: Sizes.paddingWidget(context),
          ),
          itemBuilder: (context, index) {
            var pastOrder = model.salesOrderList[index];
            return pastOrderListTile(pastOrder, context);
          },
        ),
      );
    }
  }

  Widget pastOrderListTile(SalesOrder pastOrder, BuildContext context) {
    var titleTextStyle = const TextStyle(fontWeight: FontWeight.bold);
    var subTitleTextStyle = Theme.of(context).textTheme.bodyMedium;
    var priceTextStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        );

    return GestureDetector(
      onTap: () async {
        var result = await locator
            .get<NavigationService>()
            .navigateTo(pastOrdersDetailViewRoute, arguments: pastOrder);
        if (result != null) {
          var res = result as List;
          if (res[0] == true) {
            model.refresh();
            locator.get<CartPageViewModel>().updateCart();
            await Future.delayed(const Duration(milliseconds: 50));
            model.refresh();
          }
        }
      },
      child: SizedBox(
        height: 180,
        child: Card(
          margin: EdgeInsets.only(bottom: Sizes.paddingWidget(context)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.paddingWidget(context),
              vertical: Sizes.paddingWidget(context),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pastOrder.name ?? '',
                                style: subTitleTextStyle,
                              ),
                              SizedBox(
                                  height: Sizes.smallPaddingWidget(context)),
                              Text(
                                'Date : ${defaultDateFormat(pastOrder.transactiondate!)}',
                                style: subTitleTextStyle,
                              ),
                              SizedBox(
                                  height: Sizes.smallPaddingWidget(context)),
                              Text(
                                'Qty : ${pastOrder.totalqty}',
                                style: subTitleTextStyle,
                              ),
                              SizedBox(
                                  height: Sizes.smallPaddingWidget(context)),
                              model.imagesUrlMap[pastOrder.name] == null
                                  ? Container()
                                  : Row(
                                      children: [
                                        StackedImages(
                                          imageUrls: model
                                              .imagesUrlMap[pastOrder.name],
                                          isImageLoading: model.isImagesLoading,
                                        ),
                                        SizedBox(
                                            width: Sizes.smallPaddingWidget(
                                                context)),
                                        Text(
                                          '${model.imagesUrlMap[pastOrder.name].length > 3 ? '+${model.imagesUrlMap[pastOrder.name].length - 3}' : ''}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'View',
                            style: subTitleTextStyle,
                          ),
                          SizedBox(
                            width: Sizes.extraSmallPaddingWidget(context),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: displayWidth(context) < 600 ? 14 : 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        ],
                      ),
                      Text(
                        Formatter.formatter.format(pastOrder.grandtotal),
                        style: GoogleFonts.inter(textStyle: priceTextStyle),
                      ),
                      addToCartButton(pastOrder, context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future openSalesOrderDetailBottomSheet(
      BuildContext context, SalesOrder salesOrder) async {
    // navigate to sales order detail

    await showModalBottomSheet(
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: displayWidth(context),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Corners.xxxlRadius,
          topRight: Corners.xxxlRadius,
        ),
      ),
      context: context,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: PastOrdersDetailView(
                salesOrder: salesOrder,
              ),
            );
          },
        );
      },
    );
  }

  Widget addToCartButton(SalesOrder pastOrder, BuildContext context) {
    return pastOrderReusableBtn('Add To Cart', () async {
      await model.addToCart(pastOrder, context);
      locator.get<CartPageViewModel>().updateCart();
      await Future.delayed(const Duration(milliseconds: 50));
      model.refresh();
      flutterStyledToast(
        context,
        'Sales order items added to cart!',
        CustomTheme.onPrimaryColorLight,
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CustomTheme.successColor,
            ),
      );
    }, pastOrder, context);
  }

  Widget pastOrderReusableBtn(String text, void Function()? onPressed,
      SalesOrder pastOrder, BuildContext context) {
    return Skeleton.ignore(
      child: SizedBox(
        height: displayWidth(context) < 600 ? 32 : 50,
        // width: 110,
        child: TextButton(
          style: ButtonStyle(
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
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
          ),
        ),
      ),
    );
  }

  Widget table(SalesOrder pastOrder, BuildContext context) {
    // var columns = model.customerModel.salesTeam;
    var list = [];
    var baseurl = locator.get<StorageService>().apiUrl;

    Map<String, dynamic> pastOrderJson(SalesOrderItems so, Product item) => {
          'delivery_date': so.deliverydate,
          'item_code': so.itemcode,
          'item_name': so.itemname,
          'amount': so.amount,
          'rate': so.rate,
          'qty': so.qty,
          'image': item.image != null ? '$baseurl${item.image}' : item.image,
          'description': item.description,
          'item_group': item.itemGroup,
        };

    pastOrder.salesOrderItems?.forEach((e) {
      var item = model.itemsList
          .firstWhere((element) => element.itemCode == e.itemcode);
      // return list.add(e.salesOrderToJson());
      return list.add(pastOrderJson(e, item));
    });

    return Padding(
      padding: EdgeInsets.only(left: Sizes.paddingWidget(context)),
      child: JsonTable(
        list,
        // showColumnToggle: true,
        // paginationRowCount: 50,
        columns: [
          JsonTableColumn('item_code', label: 'Item Code'),
          JsonTableColumn('item_group', label: 'Item Group'),
          JsonTableColumn('delivery_date', label: 'Delivery Date'),
          JsonTableColumn('qty', label: 'Qty'),
          JsonTableColumn('rate', label: 'Rate'),
          JsonTableColumn('amount', label: 'Amount'),
        ],
        tableCellBuilder: (value) => Sizes.tableCellBuilder(value, context),
        tableHeaderBuilder: (header) =>
            Sizes.tableHeaderBuilder(header, context),
      ),
    );
  }
}
