import 'package:flutter/foundation.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/colors.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/viewmodels/search_page_viewmodel.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'image_widget_native.dart' if (dart.library.html) 'image_widget_web.dart'
    as image_widget;

class SearchPageView extends StatelessWidget {
  final String? fromView;
  SearchPageView({super.key, this.fromView});

  final searchController = TextEditingController();
  static const greenColor = Color(0xFF028431);

  @override
  Widget build(BuildContext context) {
    return BaseView<SearchPageViewModel>(
      onModelReady: (model) async {
        // get item code and item name list
        await model.getItemsList(context);
        await model.getItems();
        await model.getCartItems();
      },
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            // Set the result here when the back button is pressed
            locator.get<NavigationService>().pop(result: true);
            return false; // Prevents default back navigation
          },
          child: Scaffold(
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(65),
                child: commonAppBar(model, context)),
            body: model.state == ViewState.busy
                ? WidgetsFactoryList.circularProgressIndicator()
                : SafeArea(
                    child: Column(
                      children: [
                        model.searchItemsList.isEmpty
                            ? Container()
                            : Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: model.searchItemsList.length,
                                  itemBuilder: (context, index) {
                                    var item = model.searchItemsList[index];
                                    var baseurl =
                                        locator.get<StorageService>().apiUrl;
                                    var imageDimension =
                                        displayWidth(context) < 600
                                            ? 38.0
                                            : 55.0;
                                    return ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal:
                                            Sizes.smallPaddingWidget(context) *
                                                1.5,
                                      ),
                                      horizontalTitleGap:
                                          Sizes.smallPaddingWidget(context),
                                      key: Key(item.item),
                                      leading:
                                          //TODO: change to images
                                          item.image.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      Corners.lgBorder,
                                                  child: image_widget.imageWidget(
                                                      '${locator.get<StorageService>().apiUrl}${item.image}',
                                                      imageDimension,
                                                      imageDimension),
                                                )
                                              : Container(
                                                  width: imageDimension,
                                                  height: imageDimension,
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        Corners.xxlBorder,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                        Images.imageNotFound,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.item,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 90,
                                            child: Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: TextButton.icon(
                                                style: ButtonStyle(
                                                  shape: WidgetStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          Corners.lgBorder,
                                                      side: BorderSide(
                                                          color: model
                                                                  .itemInCart(
                                                                      item.item)
                                                              ? CustomTheme
                                                                  .successColor
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                          model.addToCartPressed[
                                                                      index] ==
                                                                  true
                                                              ? CustomTheme
                                                                  .successColor
                                                              : Theme.of(
                                                                      context)
                                                                  .scaffoldBackgroundColor),
                                                ),
                                                icon:
                                                    model.itemInCart(item.item)
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            size: 13,
                                                            color: CustomTheme
                                                                .successColor,
                                                          )
                                                        : null,
                                                onPressed: () async {
                                                  model.setAddToCartPressed(
                                                      index, true);
                                                  if (model.dropdownText ==
                                                      model.dropdownList[1]) {
                                                    var product = model
                                                        .productsList
                                                        .firstWhere((e) =>
                                                            e.itemName ==
                                                            item.item);
                                                    await OrderitWidgets
                                                        .addToCart(
                                                      product,
                                                      context,
                                                      position:
                                                          StyledToastPosition
                                                              .top,
                                                    );
                                                  } else {
                                                    var product = model
                                                        .productsList
                                                        .firstWhere((e) =>
                                                            e.itemCode ==
                                                            item.item);
                                                    await OrderitWidgets
                                                        .addToCart(
                                                      product,
                                                      context,
                                                      position:
                                                          StyledToastPosition
                                                              .top,
                                                    );
                                                  }
                                                  await model.getCartItems();
                                                  await Future.delayed(
                                                      const Duration(
                                                          seconds: 1));

                                                  model.setAddToCartPressed(
                                                      index, false);
                                                },
                                                label: Text(
                                                  model.itemInCart(item.item)
                                                      ? 'Added'
                                                      : 'Add',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                          color: model.addToCartPressed[
                                                                      index] ==
                                                                  true
                                                              ? Colors.white
                                                              : model.itemInCart(
                                                                      item.item)
                                                                  ? CustomTheme
                                                                      .successColor
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        if (model.dropdownText ==
                                            model.dropdownList[1]) {
                                          var product = model.productsList
                                              .firstWhere((e) =>
                                                  e.itemName == item.item);
                                          await locator
                                              .get<NavigationService>()
                                              .navigateTo(itemsDetailViewRoute,
                                                  arguments: product.itemCode);
                                        } else {
                                          await locator
                                              .get<NavigationService>()
                                              .navigateTo(itemsDetailViewRoute,
                                                  arguments: item.item);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  AppBar commonAppBar(SearchPageViewModel model, BuildContext context) {
    return AppBar(
      title: searchBar(model, context),
      leadingWidth: 0,
      titleSpacing: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [],
    );
  }

  Widget searchBar(SearchPageViewModel model, BuildContext context) {
    return Container(
      height: Sizes.buttonHeightWidget(context),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: Corners.lgBorder,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        horizontal: Sizes.paddingWidget(context),
        // vertical: Sizes.smallPaddingWidget(context),
      ),
      // padding: const EdgeInsets.symmetric(horizontal: Sizes.smallPadding),
      child: Row(
        children: [
          /*
          IconButton(
              icon: Icon(
                defaultTargetPlatform == TargetPlatform.iOS
                    ? Icons.arrow_back_ios
                    : Icons.arrow_back,
              ),
              onPressed: () async {
                locator.get<NavigationService>().pop();
                // Navigator.pop(context, '');
              }),
          */
          // SizedBox(
          //   width: Sizes.smallPaddingWidget(context),
          // ),
          SizedBox(width: Sizes.smallPaddingWidget(context)),
          GestureDetector(
            onTap: () => locator.get<NavigationService>().pop(result: true),
            child: Icon(
              defaultTargetPlatform == TargetPlatform.iOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
              size: 24,
              color: CustomTheme.iconColor,
            ),
          ),
          Expanded(
            child: SizedBox(
              child: TextFormField(
                key: const Key(TestCasesConstants.searchField),
                // keyboardType: TextInputType.,
                onFieldSubmitted: (value) {},
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.onPrimary,
                  hintText: 'Search...',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: CustomTheme.iconColor),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  filled: true,
                  isDense: true,
                ),
                controller: searchController,
                onChanged: (item) {
                  var itemLowercase = item.toLowerCase();
                  model.search(itemLowercase);
                },
              ),
            ),
          ),
          // SizedBox(
          //   width: Sizes.smallPaddingWidget(context),
          // ),
          /*
          VerticalDivider(
            endIndent: Sizes.smallPaddingWidget(context),
            indent: Sizes.smallPaddingWidget(context),
          ),
          dropDownButton(model, context),
          */
          // SizedBox(
          //   width: Sizes.extraSmallPaddingWidget(context),
          // ),
          // displayWidth(context) < 600
          //     ? Container()
          //     : SizedBox(width: Sizes.smallPaddingWidget(context)),
          // barcode scan button
          // barcodeScan(model),
          // displayWidth(context) < 600
          //     ? Container()
          //     : SizedBox(width: Sizes.smallPaddingWidget(context)),
        ],
      ),
    );
  }

  // barcode scan widget
  Widget barcodeScan(SearchPageViewModel model) {
    return GestureDetector(
      onTap: () async {
        await model.scanBarcodeFlutter();
        searchController.text = model.itemFromBarcode!;
      },
      child: const Padding(
        padding: EdgeInsets.only(left: Sizes.extraSmallPadding),
        child: Icon(
          Icons.camera_alt,
        ),
      ),
    );
  }

  Widget dropDownButton(SearchPageViewModel model, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.smallPadding),
      // height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary,
          borderRadius: Corners.xxlBorder),
      child: DropdownButtonHideUnderline(
        key: const Key(TestCasesConstants.itemDropdown),
        child: DropdownButton<String>(
          value: model.dropdownText,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 20,
          underline: Container(
            height: 2,
            color: Theme.of(context).primaryColor,
          ),
          onChanged: model.setText,
          items: model.dropdownList.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.toString(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
