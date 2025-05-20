import 'package:google_fonts/google_fonts.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/common/widgets/sliver_common.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/base_view.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/draft.dart';
import 'package:orderit/orderit/viewmodels/draft_detail_viewmodel.dart';

import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/formatter.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'image_widget_native.dart' if (dart.library.html) 'image_widget_web.dart'
    as image_widget;

class DraftDetailView extends StatelessWidget {
  const DraftDetailView({super.key, this.draft});

  final Draft? draft;

  @override
  Widget build(BuildContext context) {
    return BaseView<DraftDetailViewModel>(
      onModelReady: (model) async {
        await model.updateDraft(draft);
        await model.initQuantityController();
      },
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: CustomTheme.scaffoldBackgroundColorLight,
          appBar: Common.commonAppBar(
              'Wishlist',
              [
                updateButton(model, context),
                SizedBox(
                  width: Sizes.paddingWidget(context),
                ),
              ],
              context),
          body: model.state == ViewState.busy
              ? WidgetsFactoryList.circularProgressIndicator()
              : draftDetail(model, context),
        );
      },
    );
  }

  Widget draftDetail(DraftDetailViewModel model, BuildContext context) {
    var draft = model.draft;
    var textStyle = Theme.of(context).textTheme.titleSmall;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.paddingWidget(context)),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Sizes.paddingWidget(context)),
                verticalPaddingSmall(context),
                Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Sizes.paddingWidget(context),
                      vertical: Sizes.paddingWidget(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Common.reusableRowWidget(
                            'Customer', draft?.customer ?? '', context),
                        verticalPaddingSmall(context),
                        Common.reusableRowWidget(
                            'Date',
                            DateFormat('dd-MM-yyyy HH:MM:ss')
                                .format(DateTime.parse(draft!.time!)),
                            context),
                        verticalPaddingSmall(context),
                        Common.reusableRowWidget(
                            'Total Items',
                            draft.cartItems != null
                                ? '${draft.cartItems?.length.toString()}'
                                : '0',
                            context),
                        verticalPaddingSmall(context),
                        Common.reusableRowWidget(
                            'Total Price',
                            Formatter.formatter.format(draft.totalPrice),
                            context,
                            textStyle: GoogleFonts.inter(
                                textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ))),
                      ],
                    ),
                  ),
                ),
                verticalPaddingMedium(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    createCart(model, context),
                    SizedBox(
                      width: Sizes.smallPaddingWidget(context),
                    ),
                    clearCartAndAppend(model, context),
                  ],
                ),
                verticalPaddingMedium(context),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == draft.cartItems!.length - 1) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Corners.xxlRadius,
                    bottomRight: Corners.xxlRadius,
                  ),
                  child: cartItem(index, model, context),
                );
              }
              if (index == 0) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Corners.xxlRadius,
                    topRight: Corners.xxlRadius,
                  ),
                  child: Column(
                    children: [
                      cartItem(index, model, context),
                      const Divider(
                        endIndent: 0,
                        height: 0,
                        indent: 0,
                        thickness: 1,
                      ),
                    ],
                  ),
                );
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
            }, childCount: draft.cartItems?.length),
          ),
          CustomSliverSizedBox(
            height: Sizes.bottomPaddingWidget(context),
          )
        ],
      ),
    );
  }

  Widget updateButton(DraftDetailViewModel model, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await model.updateDrafts();
        flutterStyledToast(context, 'Draft updated Successfully!',
            CustomTheme.toastMessageBgColor,
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Corners.lgBorder,
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.paddingWidget(context) * 1.5,
            vertical: Sizes.extraSmallPaddingWidget(context) * 1.5,
          ),
          child: Text(
            'Update',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  Widget cartItem(int index, DraftDetailViewModel model, BuildContext context) {
    var imageDimension = displayWidth(context) < 600 ? 38.0 : 62.0;
    var btnDimension = displayWidth(context) < 600 ? 28.0 : 52.0;
    var iconSize = displayWidth(context) < 600 ? 20.0 : 32.0;
    var item = model.draft?.cartItems?[index];
    return Container(
        height: 90,
        color: Theme.of(context).cardColor,
        key: Key(item?.itemName ?? ''),
        child: cartItemData(
            item!, index, iconSize, imageDimension, btnDimension, context));
  }

  Widget cartItemRate(Cart item, int index, BuildContext context) {
    var textStyle = TextStyle(fontSize: displayWidth(context) < 600 ? 14 : 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price : ${Formatter.formatter.format((item.rate ?? 0))} ',
          style: GoogleFonts.inter(textStyle: textStyle),
        ),
        Text(
          'Total : ${Formatter.formatter.format((item.rate ?? 0) * item.quantity)} ',
          style: GoogleFonts.inter(
              textStyle: textStyle.copyWith(
            fontWeight: FontWeight.bold,
          )),
        ),
      ],
    );
  }

  Widget cartItemRateTablet(Cart item, int index, BuildContext context) {
    var textStyle = Theme.of(context).textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${Formatter.formatter.format((item.rate ?? 0))} ',
          style: GoogleFonts.inter(textStyle: textStyle),
        ),
        Text(
          'Total : ${Formatter.formatter.format((item.rate ?? 0) * item.quantity)} ',
          style: GoogleFonts.inter(
              textStyle: textStyle?.copyWith(
            fontWeight: FontWeight.bold,
          )),
        ),
      ],
    );
  }

  Widget cartItemData(Cart item, int index, double iconSize,
      double imageDimension, double btnDimension, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Sizes.smallPaddingWidget(context), vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          removeCartItem(index, context),
          SizedBox(width: Sizes.extraSmallPaddingWidget(context)),
          item.imageUrl == null || item.imageUrl == ''
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
                  : ClipRRect(
                      borderRadius: Corners.lgBorder,
                      child: image_widget.imageWidget(
                          '${locator.get<StorageService>().apiUrl}${item.imageUrl}',
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
                    item.itemName ?? '',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  cartItemRate(item, index, context),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: Sizes.extraSmallPaddingWidget(context),
          ),
          incDecBtn(item, index, btnDimension, iconSize, context),
        ],
      ),
    );
  }

  Widget removeCartItem(int index, BuildContext context) {
    var model = locator.get<DraftDetailViewModel>();
    return GestureDetector(
      onTap: () async {
        await model.removeDraftItemDialog(index, context);
      },
      child: Icon(Icons.close, size: displayWidth(context) < 600 ? 18 : 28),
    );
  }

  Widget incDecBtn(Cart item, int index, double btnDimension, double iconSize,
      BuildContext context) {
    var model = locator.get<DraftDetailViewModel>();
    return model.quantityControllerList.isNotEmpty
        ? Container(
            padding: EdgeInsets.symmetric(
                vertical: Sizes.extraSmallPaddingWidget(context),
                horizontal: Sizes.smallPaddingWidget(context) * 0.8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: Corners.lgBorder,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (item.quantity == 1) {
                      await model.removeDraftItemDialog(index, context);
                    } else {
                      await model.decrement(index, context);
                    }
                  },
                  child: SizedBox(
                    width: btnDimension,
                    height: btnDimension,
                    child: Icon(
                      Icons.remove,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: iconSize,
                      key: Key('${Strings.decrementButtonKey}${item.itemCode}'),
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
                            color: Theme.of(context).scaffoldBackgroundColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).scaffoldBackgroundColor),
                      ),
                    ),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onChanged: (String value) async {
                      if (value.isEmpty) {
                        // do nothing
                      } else {
                        if (value == '0') {
                          await model.removeDraftItemDialog(index, context);
                        } else {
                          model.setQty(index, value, context);
                        }
                      }
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () => model.increment(index, context),
                  child: SizedBox(
                    width: btnDimension,
                    height: btnDimension,
                    child: Icon(
                      Icons.add,
                      size: iconSize,
                      color: Theme.of(context).colorScheme.onSecondary,
                      key: Key('${Strings.incrementButtonKey}${item.itemCode}'),
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
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

  Widget createCart(DraftDetailViewModel model, BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 55,
        child: TextButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                  borderRadius: Corners.lgBorder,
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary)),
            ),
            backgroundColor:
                WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
          ),
          onPressed: () async {
            await model.createCart(context);
            locator.get<NavigationService>().pop(result: true);
          },
          child: Text(
            'Add to Cart',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: Sizes.fontSizeTextButtonWidget(context),
                ),
          ),
        ),
      ),
    );
  }

  Widget clearCartAndAppend(DraftDetailViewModel model, BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 55,
        child: TextButton(
          style: const ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: Corners.lgBorder,
              ),
            ),
            backgroundColor: WidgetStatePropertyAll(Color(0xFFBE2527)),
          ),
          onPressed: () async {
            await model.clearCartAndAppend(context);
            locator.get<NavigationService>().pop(result: true);
          },
          child: Text(
            'Clear & Append',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: Sizes.fontSizeTextButtonWidget(context),
                ),
          ),
        ),
      ),
    );
  }
}
