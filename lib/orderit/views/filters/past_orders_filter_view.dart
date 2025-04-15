import 'package:intl/intl.dart';
import 'package:orderit/common/models/custom_textformformfield.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/filters/past_orders_filter_viewmodel.dart';
import 'package:orderit/util/constants/lists.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:flutter/material.dart';

class PastOrdersFilterView extends StatelessWidget {
  const PastOrdersFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<PastOrdersFilterViewModel>(
      onModelReady: (model) async {},
      builder: (context, model, child) {
        return Wrap(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Sizes.paddingWidget(context)),
              child: Column(
                children: [
                  SizedBox(height: Sizes.paddingWidget(context)),
                  Common.bottomSheetHeader(context),
                  SizedBox(height: Sizes.paddingWidget(context)),
                  Row(
                    children: [
                      Text(
                        'Set Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: Sizes.paddingWidget(context)),
                  statusDropdownField(model, context),
                  SizedBox(height: Sizes.paddingWidget(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: fromDateField(model, context)),
                      SizedBox(width: Sizes.smallPaddingWidget(context)),
                      Expanded(child: toDateField(model, context)),
                    ],
                  ),
                  SizedBox(height: Sizes.paddingWidget(context)),
                  applyFilterButton(model, context),
                  SizedBox(height: Sizes.paddingWidget(context)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future _selectStartDate(
      PastOrdersFilterViewModel model, BuildContext context) async {
    var picked = await showDatePicker(
        context: context,
        initialDate: model.startDate,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));
    if (picked != null) {
      model.setStartDate(picked);
      model.startDateController.text =
          DateFormat('yyyy-MM-dd').format(picked).toString();
    }
  }

  Widget fromDateField(PastOrdersFilterViewModel model, BuildContext context) {
    return GestureDetector(
      onTap: () => _selectStartDate(model, context),
      child: AbsorbPointer(
        child: CustomTextFormField(
          controller: model.startDateController,
          keyboardType: TextInputType.datetime,
          decoration: Common.inputDecoration(),
          label: 'From Date',
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Future _selectEndDate(
      PastOrdersFilterViewModel model, BuildContext context) async {
    var picked = await showDatePicker(
        context: context,
        initialDate: model.endDate,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));
    if (picked != null) {
      model.setEndDate(picked);
      model.endDateController.text =
          DateFormat('yyyy-MM-dd').format(picked).toString();
    }
  }

  Widget toDateField(PastOrdersFilterViewModel model, BuildContext context) {
    return GestureDetector(
      onTap: () => _selectEndDate(model, context),
      child: AbsorbPointer(
        child: CustomTextFormField(
          controller: model.endDateController,
          keyboardType: TextInputType.datetime,
          decoration: Common.inputDecoration(),
          label: 'To Date',
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget statusDropdownField(
      PastOrdersFilterViewModel model, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        right: Sizes.extraSmallPaddingWidget(context),
        left: Sizes.smallPaddingWidget(context),
      ),
      width: displayWidth(context),
      decoration: BoxDecoration(
          border: Border.all(color: CustomTheme.borderColor, width: 1),
          borderRadius: Corners.xxlBorder),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: model.statusTextSO,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 20,
          onChanged: (value) async {
            model.setStatusSO(value);
          },
          items: Lists.salesOrderStatus
              // .sublist(1)
              .map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.toString(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget clearFilter(PastOrdersFilterViewModel model, BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: Sizes.buttonHeightWidget(context),
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  WidgetStatePropertyAll(CustomTheme.errorColorLight)),
          onPressed: () {
            model.clearData();
          },
          child: const Text('Clear'),
        ),
      ),
    );
  }

  Widget applyFilterButton(
      PastOrdersFilterViewModel model, BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: Sizes.buttonHeightWidget(context),
        width: displayWidth(context),
        child: ElevatedButton(
          onPressed: () async {
            var filters = [];
            filters.clear();
            if (model.statusTextSO?.isNotEmpty == true) {
              filters.add(["Sales Order", "status", "=", model.statusTextSO]);
            }
            if (model.startDateController.text.isNotEmpty &&
                model.endDateController.text.isNotEmpty) {
              filters.add([
                "Sales Order",
                "creation",
                "Between",
                [
                  "${model.startDateController.text}",
                  "${model.endDateController.text}"
                ]
              ]);
            }

            locator.get<NavigationService>().pop(
                  result: filters.isNotEmpty ? filters : model.statusTextSO,
                );
          },
          child: const Text('Done'),
        ),
      ),
    );
  }
}
