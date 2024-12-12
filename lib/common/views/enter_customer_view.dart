import 'dart:convert';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/common/widgets/custom_typeahead_formfield.dart';
import 'package:orderit/common/widgets/typeahead_widgets.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/common/viewmodels/enter_customer_viewmodel.dart';
import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnterCustomerView extends StatelessWidget {
  EnterCustomerView({
    super.key,
    required this.fromRoute,
  });
  final String? fromRoute;
  final _formKey = GlobalKey<FormState>(debugLabel: 'enter_customer_key');

  @override
  Widget build(BuildContext context) {
    return BaseView<EnterCustomerViewModel>(
      onModelReady: (model) async {
        model.getUser();
        var connectivityStatus =
            Provider.of<ConnectivityStatus>(context, listen: false);
        if (connectivityStatus == ConnectivityStatus.wifi ||
            connectivityStatus == ConnectivityStatus.cellular) {
          var statusCode = await model.checkSessionExpired();
          if (statusCode != 200) {
            // logout
            locator.get<StorageService>().loggedIn = false;
            await locator
                .get<NavigationService>()
                .pushNamedAndRemoveUntil(loginViewRoute, (_) => false);
          }
          // do nothing
          else {}
        }
        model.init();
        await model.getCustomer(fromRoute, context);
        await model.getGlobalDefaults();
        // if login has changed then recache doctypes
        if (locator.get<StorageService>().isLoginChanged) {
          debugPrint(
              'is login changed ${locator.get<StorageService>().isLoginChanged}');
          // set isLoginChanged to false and recache doctypes and target and ach
          locator.get<StorageService>().isLoginChanged = false;
          var doctypeCacheService = locator.get<DoctypeCachingService>();
          await doctypeCacheService.cacheCustomerNameList(
              Strings.customerNameList, connectivityStatus);
          await doctypeCacheService.cacheCustomer(
              Strings.customer, connectivityStatus);
          await doctypeCacheService.cacheSalesOrder(
              Strings.salesOrder, connectivityStatus);
          await doctypeCacheService.cacheItemGroups(
              Strings.itemGroupTree, connectivityStatus);
          await doctypeCacheService.cacheItem(Strings.item, connectivityStatus);
          await doctypeCacheService.cacheCurrency(
              Strings.currency, connectivityStatus);
        }
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: Common.commonAppBar(
            'Customer Selection',
            [
              Common.profileReusableWidget(model.user, context),
              SizedBox(width: Sizes.paddingWidget(context)),
            ],
            context,
            showBackBtn: false,
          ),
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(Sizes.paddingWidget(context)),
                    child: Form(
                      key: _formKey,
                      child: GestureDetector(
                        onTap: () {
                          model.unfocus(context);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            Text(
                              'Select a Customer from the list to Proceed',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: displayWidth(context) < 600
                                  ? Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )
                                  : Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                            ),
                            const SizedBox(height: 25),
                            customerField(model, context),
                            SizedBox(
                              height: Sizes.paddingWidget(context),
                            ),
                            nextButtonWidget(model, context),
                            SizedBox(
                              height: Sizes.paddingWidget(context),
                            ),
                            model.customerDoctype.docs?.isNotEmpty == true
                                ? customerData(model, context)
                                : const SizedBox(),
                            model.accountsRecievable.result?.isNotEmpty == true
                                ? Column(
                                    children: [
                                      Common.widgetSpacingVerticalLg(),
                                      scrollToViewTableBelow(context),
                                      Common.widgetSpacingVerticalLg(),
                                    ],
                                  )
                                : const SizedBox(),
                            model.accountsRecievable.result?.isNotEmpty == true
                                ? displayWidth(context) < 600
                                    ? table(model, displayWidth(context) * 0.5,
                                        displayWidth(context) * 0.35, context)
                                    : table(model, displayWidth(context) * 0.25,
                                        displayWidth(context) * 0.2, context)
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget scrollToViewTableBelow(BuildContext context) {
    var style = CustomTheme.fontStyle.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Scroll ',
            style: style,
          ),
          const WidgetSpan(
            child: Icon(Icons.arrow_back, size: 16),
          ),
          TextSpan(
            text: ' or ',
            style: style,
          ),
          const WidgetSpan(
            child: Icon(Icons.arrow_forward, size: 16),
          ),
          TextSpan(
            text: ' from due date column to view receivable details',
            style: style,
          )
        ],
      ),
    );
  }

  Widget customerData(EnterCustomerViewModel model, BuildContext context) {
    double? creditLimit = 0.0;
    double? outstanding = 0.0;
    double? billingAsOnDate = 0.0;
    if (model.customerDoctype.docs?.isNotEmpty == true) {
      var data = model.customerDoctype.docs?[0];
      if (data?.creditLimits?.isNotEmpty == true) {
        creditLimit = data?.creditLimits?[0].creditLimit;
      }
      if (data?.oOnload?.dashboardInfo?.isNotEmpty == true) {
        outstanding = data?.oOnload?.dashboardInfo?[0].totalUnpaid;
        billingAsOnDate = data?.oOnload?.dashboardInfo?[0].billingThisYear;
      }
    }

    return SizedBox(
      width: displayWidth(context),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: Sizes.smallPaddingWidget(context),
              horizontal: Sizes.smallPaddingWidget(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Credit Limit : ${Formatter.formatter.format(creditLimit)}',
                style: const TextStyle(
                  color: Color(0xFF189333),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: Sizes.extraSmallPaddingWidget(context),
              ),
              Text(
                'Outstanding : ${Formatter.formatter.format(outstanding)}',
                style: const TextStyle(
                  color: Color(0xFFBE2527),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: Sizes.extraSmallPaddingWidget(context),
              ),
              Text(
                'Billing as on date : ${Formatter.formatter.format(billingAsOnDate)}',
                style: const TextStyle(
                  color: Color(0xFF84292A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Table with freezed column
  Widget table(EnterCustomerViewModel model, double freezedColumnWidth,
      double columnWidth, BuildContext context) {
    final headers = <String>[
      'Invoice No',
      'Due Date',
      'Paid Amt',
      '0-30',
      '31-60',
      '61-90',
      '91-120',
      '120-Above'
    ];
    final data = <List<TableData>>[];
    var listData = model.response['message']['result'] as List;
    var totalRow = listData[listData.length - 1] as List;
    var totalRowTextStyle = const TextStyle(fontWeight: FontWeight.bold);
    var commonWidth = columnWidth;

    if (model.accountsRecievable.result?.isNotEmpty == true) {
      for (var r in model.accountsRecievable.result!) {
        data.add([
          TableData(
              value:
                  '${(model.accountsRecievable.result!.indexOf(r) + 1)}. ${r.voucherNo}',
              width: freezedColumnWidth,
              alignment: Alignment.centerLeft),
          TableData(
              value: r.dueDate != null ? r.dueDate! : '',
              width: commonWidth,
              alignment: Alignment.centerRight),
          TableData(
              value: r.paidInAccountCurrency != null
                  ? Formatter.formatter.format(r.paidInAccountCurrency)
                  : '0',
              width: commonWidth,
              alignment: Alignment.centerRight),
          TableData(
              value:
                  r.range1 != null ? Formatter.formatter.format(r.range1) : '0',
              width: commonWidth,
              alignment: Alignment.centerRight),
          TableData(
              value:
                  r.range2 != null ? Formatter.formatter.format(r.range2) : '0',
              width: commonWidth,
              alignment: Alignment.centerRight),
          TableData(
              value:
                  r.range3 != null ? Formatter.formatter.format(r.range3) : '0',
              width: commonWidth,
              alignment: Alignment.centerRight),
          TableData(
              value:
                  r.range4 != null ? Formatter.formatter.format(r.range4) : '0',
              width: commonWidth,
              alignment: Alignment.centerRight),
          TableData(
              value:
                  r.range5 != null ? Formatter.formatter.format(r.range5) : '0',
              width: commonWidth,
              alignment: Alignment.centerRight),
        ]);
      }
    }

    data.add(
      [
        TableData(
            value: 'Total',
            width: freezedColumnWidth,
            isBold: true,
            alignment: Alignment.center),
        TableData(
            value: '',
            width: commonWidth,
            isBold: true,
            alignment: Alignment.center),
        TableData(
            value: totalRow[10].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[10])
                : Formatter.formatter.format(0),
            width: commonWidth,
            isBold: true,
            alignment: Alignment.centerRight),
        TableData(
            value: totalRow[14].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[14])
                : Formatter.formatter.format(0),
            width: commonWidth,
            isBold: true,
            alignment: Alignment.centerRight),
        TableData(
            value: totalRow[15].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[15])
                : Formatter.formatter.format(0),
            width: commonWidth,
            isBold: true,
            alignment: Alignment.centerRight),
        TableData(
            value: totalRow[16].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[16])
                : Formatter.formatter.format(0),
            width: commonWidth,
            isBold: true,
            alignment: Alignment.centerRight),
        TableData(
            value: totalRow[17].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[17])
                : Formatter.formatter.format(0),
            width: commonWidth,
            isBold: true,
            alignment: Alignment.centerRight),
        TableData(
            value: totalRow[18].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[18])
                : Formatter.formatter.format(0),
            width: commonWidth,
            isBold: true,
            alignment: Alignment.centerRight),
      ],
    );

    return ClipRRect(
      borderRadius: Corners.xxlBorder,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Freezed Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCell(headers[0], freezedColumnWidth, context),
              Divider(
                indent: 0,
                endIndent: 0,
                color: CustomTheme.fillColorGrey,
                height: 1,
              ),
              ...data
                  .map((row) => _buildCell(
                      row[0].value, freezedColumnWidth, row[0].isBold, context,
                      fontSize: 12, alignment: row[0].alignment))
                  .toList(),
            ],
          ),
          // Scrollable Columns
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: headers
                        .sublist(2)
                        .map((header) =>
                            _buildHeaderCell(header, commonWidth, context))
                        .toList(),
                  ),
                  Divider(
                    indent: 0,
                    endIndent: 0,
                    color: CustomTheme.fillColorGrey,
                    height: 1,
                  ),
                  Column(
                    children: data.map((row) {
                      return Row(
                        children: row
                            .sublist(2)
                            .map((cell) => _buildCell(
                                cell.value, cell.width, cell.isBold, context,
                                alignment: cell.alignment))
                            .toList(),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width, BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            width: width,
            height: 50,
            decoration: BoxDecoration(
              color: CustomTheme.tableHeaderColor,
            ),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          VerticalDivider(
            color: CustomTheme.fillColorGrey,
            thickness: 1,
            width: 1,
            endIndent: 0,
            indent: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
      String text, double width, bool isBold, BuildContext context,
      {double? fontSize, AlignmentGeometry? alignment}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Sizes.smallPaddingWidget(context)),
            alignment: alignment ?? Alignment.center,
            width: width,
            height: displayWidth(context) < 600 ? 35 : 40,
            color: Colors.white,
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
              ),
            ),
          ),
          VerticalDivider(
            color: CustomTheme.fillColorGrey,
            thickness: 1,
            width: 1,
            endIndent: 0,
            indent: 0,
          ),
        ],
      ),
    );
  }
  /*
  // simpled table with no freezed columns
  Widget table(EnterCustomerViewModel model, BuildContext context) {
    var rows = <DataRow>[];
    var listData = model.response['message']['result'] as List;
    var totalRow = listData[listData.length - 1] as List;
    var totalRowTextStyle = const TextStyle(fontWeight: FontWeight.bold);

    if (model.accountsRecievable.result?.isNotEmpty == true) {
      for (var data in model.accountsRecievable.result!) {
        rows.add(DataRow(cells: <DataCell>[
          Common.dataCellText(
              context,
              (model.accountsRecievable.result!.indexOf(data) + 1).toString(),
              displayWidth(context) * 0.1),
          Common.dataCellText(
              context, data.voucherNo ?? '', displayWidth(context) * 0.34),
          Common.dataCellText(
              context,
              data.dueDate != null ? data.dueDate! : '',
              displayWidth(context) * 0.3),
          Common.dataCellText(
              context,
              data.paidInAccountCurrency != null
                  ? Formatter.formatter.format(data.paidInAccountCurrency)
                  : '0',
              displayWidth(context) * 0.3),
          Common.dataCellText(
              context,
              data.range1 != null
                  ? Formatter.formatter.format(data.range1)
                  : '0',
              displayWidth(context) * 0.3),
          Common.dataCellText(
              context,
              data.range2 != null
                  ? Formatter.formatter.format(data.range2)
                  : '0',
              displayWidth(context) * 0.3),
          Common.dataCellText(
              context,
              data.range3 != null
                  ? Formatter.formatter.format(data.range3)
                  : '0',
              displayWidth(context) * 0.3),
          Common.dataCellText(
              context,
              data.range4 != null
                  ? Formatter.formatter.format(data.range4)
                  : '0',
              displayWidth(context) * 0.3),
          Common.dataCellText(
              context,
              data.range5 != null
                  ? Formatter.formatter.format(data.range5)
                  : '0',
              displayWidth(context) * 0.3),
        ]));
      }

      rows.add(DataRow(cells: <DataCell>[
        Common.dataCellText(context, 'Total', displayWidth(context) * 0.1,
            textStyle: totalRowTextStyle),
        Common.dataCellText(context, '', displayWidth(context) * 0.34,
            textStyle: totalRowTextStyle),
        Common.dataCellText(context, '', displayWidth(context) * 0.3,
            textStyle: totalRowTextStyle),
        Common.dataCellText(
            context,
            totalRow[11].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[11])
                : '0.0',
            displayWidth(context) * 0.3,
            textStyle: totalRowTextStyle),
        Common.dataCellText(
            context,
            totalRow[15].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[15])
                : '0.0',
            displayWidth(context) * 0.3,
            textStyle: totalRowTextStyle),
        Common.dataCellText(
            context,
            totalRow[16].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[16])
                : '0.0',
            displayWidth(context) * 0.3,
            textStyle: totalRowTextStyle),
        Common.dataCellText(
            context,
            totalRow[17].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[17])
                : '0.0',
            displayWidth(context) * 0.3,
            textStyle: totalRowTextStyle),
        Common.dataCellText(
            context,
            totalRow[18].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[18])
                : '0.0',
            displayWidth(context) * 0.3,
            textStyle: totalRowTextStyle),
        Common.dataCellText(
            context,
            totalRow[19].toString().isNotEmpty
                ? Formatter.formatter.format(totalRow[18])
                : '0.0',
            displayWidth(context) * 0.3,
            textStyle: totalRowTextStyle),
      ]));
    }

    return Column(children: [
      Container(
        decoration: Theme.of(context).dataTableTheme.decoration,
        child: Column(
          children: [
            SingleChildScrollView(
              key: const Key(TestCasesConstants.scrollHorizontal),
              scrollDirection: Axis.horizontal,
              child: ClipRRect(
                borderRadius: Corners.xlBorder,
                child: DataTable(
                  border: TableBorder.all(color: CustomTheme.tableBorderColor),
                  headingRowColor:
                      WidgetStatePropertyAll(CustomTheme.tableHeaderColor),
                  columns: <DataColumn>[
                    Common.tableColumnText(context, 'Sr No.'),
                    Common.tableColumnText(context, 'Invoice No'),
                    Common.tableColumnText(context, 'Due Date'),
                    Common.tableColumnText(context, 'Paid Amt'),
                    Common.tableColumnText(context, '0-30'),
                    Common.tableColumnText(context, '31-60'),
                    Common.tableColumnText(context, '61-90'),
                    Common.tableColumnText(context, '91-120'),
                    Common.tableColumnText(context, '120-Above'),
                  ],
                  rows: rows,
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }
  */

  //button
  Widget nextButtonWidget(EnterCustomerViewModel model, BuildContext context) {
    return SizedBox(
      width: displayWidth(context),
      height: 50,
      child: TextButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            var storageService = locator.get<StorageService>();
            // clear customer cart so that if customer cart contains some item and user switches customer
            var data = locator.get<OfflineStorage>().getItem('cart');
            if (data['data'] != null) {
              var cart = Cartlist.fromJson(json.decode(data['data']));
              var customer = storageService.customerSelected;
              // customer currently selected is different than that one which was previously selected
              // i.e both customers are different then we should clear cart
              // notify user that cart is not empty do you want to clear cart and switch customer
              if (customer != model.customerController.text) {
                await locator.get<OfflineStorage>().putItem('cart', null);
                // await locator.get<OfflineStorage>().remove('cart');
                locator.get<CartPageViewModel>().items.clear();
                await locator.get<CartPageViewModel>().setCartItems();
                locator.get<CartPageViewModel>().updateCart();
                await locator.get<ItemsViewModel>().clearQuantityController();
              }
              //if both are same do anything keep cart as it is
              // current cart is based on this customer i.e customer selected cart exists
              else {}
            }

            // set customer in local storage
            storageService.customer = model.customerController.text;
            storageService.customerSelected = model.customerController.text;

            await locator
                .get<NavigationService>()
                .navigateTo(itemCategoryNavBarRoute);
          }
        },
        child: Text(
          Strings.proceed,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondary),
        ),
      ),
    );
  }

  Widget customerField(EnterCustomerViewModel model, BuildContext context) {
    return CustomTypeAheadFormField(
      key: const Key(Strings.customerField),
      controller: model.customerController,
      decoration: Common.inputDecoration(),
      label: 'Select Customer Name',
      required: true,
      focusNode: model.customerFocusNode,
      style: Sizes.textAndLabelStyle(context),
      labelStyle: Sizes.textAndLabelStyle(context),
      itemBuilder: (context, item) {
        return TypeAheadWidgets.itemUi(item, context);
      },
      onSuggestionSelected: (suggestion) async {
        model.customerController.text = suggestion;
        await model.getCustomerDoctype(model.customerController.text);
        await model.getAccountsRecievableReport(
            model.customerController.text, model.globalDefaults.defaultCompany);
        FocusManager.instance.primaryFocus?.unfocus();
      },
      suggestionsCallback: (pattern) {
        return TypeAheadWidgets.getSuggestions(pattern, model.customer);
      },
      transitionBuilder: (context, controller, suggestionsBox) {
        return suggestionsBox;
      },
      validator: (val) =>
          val == '' || val == null ? 'Please Select the Customer' : null,
    );
  }
}

class TableData {
  final String value;
  final double width;
  final bool isBold;
  final AlignmentGeometry? alignment;

  TableData({
    required this.value,
    required this.width,
    this.isBold = false,
    this.alignment = Alignment.center,
  });
}
