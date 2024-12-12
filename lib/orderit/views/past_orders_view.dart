import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/empty_widget.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/orderit/models/sales_order.dart';
import 'package:orderit/locators/locator.dart';
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

class PastOrdersView extends StatelessWidget {
  const PastOrdersView({super.key});
  static final isUserCustomer = locator.get<StorageService>().isUserCustomer;

  @override
  Widget build(BuildContext context) {
    return BaseView<PastOrdersViewModel>(
      onModelReady: (model) async {
        await model.getPastOrders(context);
        await model.getItems(context);
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: Common.commonAppBar(
              'Past Orders',
              [
                GestureDetector(
                    onTap: () async {
                      var result = await openPastOrderFilter(context);
                      if (result != null) {
                        var status = result as List;
                        print(status[0]);
                        model.setStatusSO(status[0]);
                        await model.getPastOrders(context);
                      }
                    },
                    child: const Icon(Icons.filter_alt)),
                SizedBox(
                  width: Sizes.smallPaddingWidget(context),
                ),
              ],
              context),
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : Stack(
                  children: [
                    PastOrderListView(model: model),
                    OrderitWidgets.floatingCartButton(context, () {
                      model.refresh();
                    }),
                  ],
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
    var titleTextStyle = const TextStyle(fontWeight: FontWeight.bold);
    var subTitleTextStyle = Theme.of(context).textTheme.labelMedium;
    var priceTextStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        );
    return model.salesOrderList.isEmpty
        ? const EmptyWidget()
        : ListView.builder(
            itemCount: model.salesOrderList.length,
            padding: EdgeInsets.symmetric(
              vertical: Sizes.paddingWidget(context),
              horizontal: Sizes.paddingWidget(context),
            ),
            itemBuilder: (context, index) {
              var pastOrder = model.salesOrderList[index];
              return GestureDetector(
                onTap: () async {
                  await locator.get<NavigationService>().navigateTo(
                      pastOrdersDetailViewRoute,
                      arguments: pastOrder);
                },
                child: SizedBox(
                  height: displayWidth(context) < 600 ? 130 : 160,
                  child: Card(
                    margin:
                        EdgeInsets.only(bottom: Sizes.paddingWidget(context)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Sizes.paddingWidget(context),
                        vertical: Sizes.paddingWidget(context),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: displayWidth(context) < 600 ? 70 : 87,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pastOrder.name ?? '',
                                          style: titleTextStyle,
                                        ),
                                        SizedBox(
                                            height: Sizes.smallPaddingWidget(
                                                context)),
                                        Text(
                                          'Date : ${defaultDateFormat(pastOrder.transactiondate!)}',
                                          style: subTitleTextStyle,
                                        ),
                                        SizedBox(
                                            height: Sizes.smallPaddingWidget(
                                                context)),
                                        Text(
                                            Formatter.formatter
                                                .format(pastOrder.grandtotal),
                                            style: priceTextStyle),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: displayWidth(context) < 600 ? 30 : 13,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'View',
                                      style: subTitleTextStyle,
                                    ),
                                    SizedBox(
                                      width: Sizes.extraSmallPaddingWidget(
                                          context),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size:
                                          displayWidth(context) < 600 ? 14 : 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: displayWidth(context) < 600
                                      ? Sizes.paddingWidget(context) * 1.5
                                      : Sizes.paddingWidget(context) * 0.5,
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
            },
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
    return pastOrderReusableBtn(Strings.add, () async {
      await model.addToCart(pastOrder, context);
    }, pastOrder, context);
  }

  Widget pastOrderReusableBtn(String text, void Function()? onPressed,
      SalesOrder pastOrder, BuildContext context) {
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
