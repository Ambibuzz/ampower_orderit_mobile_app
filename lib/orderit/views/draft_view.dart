import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/empty_widget.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/draft.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/draft_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/item_category_bottom_nav_bar_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/orderit/views/draft_detail_view.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/route/routing_constants.dart';

import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DraftView extends StatelessWidget {
  const DraftView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<DraftViewModel>(
      onModelReady: (model) async {
        await model.getDrafts();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: Common.commonAppBar('Wishlist', [], context),
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : Stack(
                  children: [
                    draftList(model.drafts, model, context),
                    OrderitWidgets.floatingCartButton(context, () {
                      model.refresh();
                    }),
                  ],
                ),
        );
      },
    );
  }

  Future<dynamic> showDraftDetailBottomSheet(
      DraftViewModel model, Draft? draft, BuildContext context) async {
    return await showModalBottomSheet(
      constraints: BoxConstraints(
        minWidth: displayWidth(context),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Corners.xxlRadius,
          topRight: Corners.xxlRadius,
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: DraftDetailView(
                draft: draft,
              ),
            );
          },
        );
      },
    );
  }

  Widget draftList(
      List<Draft>? drafts, DraftViewModel model, BuildContext context) {
    var titleTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
    );
    var subTitleTextStyle = Theme.of(context).textTheme.labelMedium;
    var priceTextStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return model.drafts?.isNotEmpty == true
        ? Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await model.getDrafts();
                  },
                  child: ListView.builder(
                    itemCount: drafts?.length,
                    padding: EdgeInsets.symmetric(
                        vertical: Sizes.paddingWidget(context),
                        horizontal: Sizes.paddingWidget(context)),
                    itemBuilder: (context, index) {
                      final draft = drafts?[index];
                      return Card(
                        margin: EdgeInsets.only(
                          bottom: Sizes.paddingWidget(context),
                        ),
                        child: Container(
                          key: Key(draft?.id ?? ''),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  Sizes.smallPaddingWidget(context) * 1.5),
                          child: Stack(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.only(
                                  top: Sizes.paddingWidget(context),
                                  bottom: Sizes.paddingWidget(context),
                                  right: Sizes.paddingWidget(context),
                                ),
                                onTap: () async {
                                  var result = await showDraftDetailBottomSheet(
                                      model, draft, context);
                                  if (result == null) {
                                    await model.getDrafts();
                                  }
                                },
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(draft?.customer ?? '',
                                        style: titleTextStyle),
                                    SizedBox(
                                        height:
                                            Sizes.smallPaddingWidget(context)),
                                    Text(
                                        'Date : ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(draft!.time!))} ',
                                        style: subTitleTextStyle),
                                    SizedBox(
                                        height:
                                            Sizes.smallPaddingWidget(context)),
                                    Text(
                                        Formatter.formatter
                                            .format(draft.totalPrice),
                                        style: priceTextStyle),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    removeDraft(model, index, context),
                                    SizedBox(
                                        height:
                                            Sizes.smallPaddingWidget(context) *
                                                2),
                                    timeLeft(draft, context),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: SizedBox(
              height: displayHeight(context) * 0.7,
              child: OrderitWidgets.emptyCartWidget(
                  'No items in wishlist!',
                  'Let’s start adding items to fill it up which you can order later!',
                  'Let’s Shop!', () {
                locator.get<ItemCategoryBottomNavBarViewModel>().setIndex(0);
                locator.get<ItemsViewModel>().updateCartItems();
                locator.get<ItemsViewModel>().initQuantityController();
              }, context),
            ),
          );
  }

  Widget timeLeft(Draft? draft, BuildContext context) {
    var dt1 = DateTime.now();
    var dt2 = DateFormat('yyyy-MM-dd hh:mm:ss').parse(draft!.expiry!);
    // var dt2 = DateTime.now();

    var text = '';
    var diff = dt2.difference(dt1);
    var daysLeft = diff.inDays;

    if (daysLeft == 0) {
      text = 'Expires Today';
    } else {
      if (daysLeft.isNegative) {
        daysLeft = diff.inDays.abs();
      }
      text = '$daysLeft Days Left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: CustomTheme.dangerColor),
          borderRadius: Corners.xxlBorder),
      child: Text(text,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: CustomTheme.dangerColor,
              )),
    );
  }

  Widget removeDraft(DraftViewModel model, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: Sizes.smallPadding, right: Sizes.extraSmallPadding),
      child: GestureDetector(
        onTap: () async {
          await model.showDialog(index, context);
        },
        child: Icon(
          Icons.delete,
          size: Sizes.iconSizeWidget(context),
          color: CustomTheme.dangerColor,
        ),
      ),
    );
  }
}
