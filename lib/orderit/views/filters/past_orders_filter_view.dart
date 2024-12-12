import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/filters/past_orders_filter_viewmodel.dart';
import 'package:orderit/util/constants/lists.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:flutter/material.dart';

class PastOrdersFilterView extends StatelessWidget {
  const PastOrdersFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<PastOrdersFilterViewModel>(
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

  Widget applyFilterButton(
      PastOrdersFilterViewModel model, BuildContext context) {
    return SizedBox(
      height: Sizes.buttonHeightWidget(context),
      width: displayWidth(context),
      child: ElevatedButton(
        onPressed: () async {
          locator.get<NavigationService>().pop(result: model.statusTextSO);
        },
        child: const Text('Done'),
      ),
    );
  }
}
