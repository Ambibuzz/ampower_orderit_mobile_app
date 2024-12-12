import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:orderit/common/models/stock_actual_qty.dart';
import 'package:orderit/common/services/stock_actual_qty_service.dart';
import 'package:orderit/common/models/user.dart';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/orderit/models/catalogue_data_model.dart';
import 'package:orderit/common/models/item_price_model.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/common_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/custom_snackbar.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/customer_model.dart';
import 'package:orderit/orderit/models/file_model.dart';
import 'package:orderit/orderit/models/item_tag_category.dart';
import 'package:orderit/orderit/models/item_tag_name.dart';
import 'package:orderit/orderit/models/tag.dart';
import 'package:orderit/orderit/services/customer_service.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/orderit/models/item_group.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/services/orderit_api_service.dart';
import 'package:orderit/orderit/services/user_service.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/widgets/orderit_widgets.dart';
import 'package:orderit/route/routing_constants.dart';
import 'package:orderit/common/services/navigation_service.dart';
import 'package:orderit/util/apiurls.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/util/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';

class ItemsViewModel extends BaseViewModel {
  List<ItemsModel> itemList = [];
  List<ItemsModel> itemCopyList = [];
  List<String> items = [];
  String weightText = '';
  String item = '';
  List<ItemGroupModel> itemGroups = [];

  String weight1 = '';
  String weight2 = '';
  ViewTypes viewType = ViewTypes.listView;
  List<Cart>? cartItems = [];
  // quantity controller
  List<QuantityControllerModel> quantityControllerList =
      <QuantityControllerModel>[];
  bool isQuantityControllerInitialized = false;
  // quantity controller catalogue view init
  var quantityControllerCatalogueView = TextEditingController();
  bool isQuantityControllerCatalogueViewInitialized = false;

  String? categorySelected;
  String? categorySelectedImage;
  List<bool> isSelected = [];
  int falseCount = 0;
  bool attributeSelected = false;

  int catalogItemIndex = 0;
  var catalogueItemQuantity = 0;
  var productList = <Product>[];
  var product = Product();
  double sliderValue = 0;

  //Carousel
  final controller = <CarouselSliderController>[];
  List<int> current = [];
  List<ItemPrice> itemPriceList = [];
  String? message;
  User user = User();
  var stockActualQtyList = <StockActualQty>[];
  var favoritesList = <String>[];

  Future getFavorites() async {
    favoritesList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedFavoritesData();
    notifyListeners();
  }

  bool isFavorite(String item) {
    if (favoritesList.isNotEmpty) {
      if (favoritesList.contains(item)) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Future toggleFavorite(String item, BuildContext context) async {
    await locator.get<OrderitWidgets>().toggleFavorite(item, context);
    favoritesList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedFavoritesData();
    notifyListeners();
  }

  Future getItemPrices() async {
    itemPriceList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedItemPriceData();
    notifyListeners();
  }

  void getUser() {
    user = locator.get<UserService>().getUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<dynamic> itemGroupTreeApi() async {
    return await locator.get<ItemsService>().itemGroupTreeList();
  }

  Future getItemFromTagData(String itemGroupName, BuildContext context) async {
    // List<ItemsModel> c = [];
    setState(ViewState.busy);
    itemList.clear();

    itemList = await locator.get<ItemsService>().getItemFromTag(itemGroupName);
    // itemList.sort((a, b) => a.itemName!.compareTo(b.itemName!));
    // itemList.forEach((item) async {
    //   double price = locator.get<ItemsService>().getPrice(item.itemCode!);
    //   int index = itemList.indexOf(item);
    //   itemList[index].price = price;
    // });
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    // print(itemList.length);
    // below code hides template
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemCopyList = itemList;
    getPrices();
    setState(ViewState.idle);
    await Future.delayed(const Duration(milliseconds: 5));
    notifyListeners();
  }

  // logic from items view
  CustomerModel customer = CustomerModel();
  ConnectivityStatus connectivityStatus = ConnectivityStatus.wifi;

  Future cacheItemGroupItemItemPrice(BuildContext context) async {
    var items =
        await locator.get<OrderitApiService>().getItems([], connectivityStatus);

    await locator.get<OfflineStorage>().putItem(
        Strings.item, jsonEncode(ProductList(productList: items).toJson()));
    // cache images
    var files = await locator.get<DoctypeCachingService>().getImages();
    await locator.get<OfflineStorage>().putItem(
        Strings.files, jsonEncode(FilesList(filesList: files).toJson()));
    showSnackBar('${Strings.item} synced ', context);

    var itemPrices = await locator
        .get<OrderitApiService>()
        .getItemPrices([], connectivityStatus);
    await locator.get<OfflineStorage>().putItem(Strings.itemPrice,
        jsonEncode(ItemPriceList(itemPriceList: itemPrices).toJson()));
    showSnackBar('${Strings.itemPrice} synced ', context);

    // cache item group list and tree both
    var itemGroups = itemGroupTreeApi();
    await locator
        .get<OfflineStorage>()
        .putItem(Strings.itemGroupTree, itemGroups);
    var itemGroupsList = await locator.get<ItemsService>().itemGroupList();
    if (itemGroupsList.isNotEmpty) {
      await locator.get<OfflineStorage>().putItem(Strings.itemGroupList,
          jsonEncode(ItemGroupList(itemGroupList: itemGroupsList).toJson()));
    }
    showSnackBar('${Strings.itemGroupTree} synced ', context);
  }

  Future getStockActualQtyList() async {
    stockActualQtyList =
        await locator.get<DoctypeCachingService>().getStockActualQtyList();
    notifyListeners();
  }

  double? getStockActualQty(String? itemCode) {
    return locator
        .get<StockActualQtyService>()
        .getStockActualQty(itemCode, stockActualQtyList);
  }

  void getConnectivityStatus(BuildContext outercontext) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      connectivityStatus =
          Provider.of<ConnectivityStatus>(outercontext, listen: false);
    });
    notifyListeners();
  }

  Future checkDoctypeCache() async {
    setState(ViewState.busy);
    try {
      await checkDoctypeCachedOrNot(connectivityStatus);
    } catch (e) {
      exception(e, '', 'checkDoctypeCache');
    } finally {
      setState(ViewState.idle);
    }
    setState(ViewState.idle);
  }

  Future checkDoctypeCachedOrNot(ConnectivityStatus connectivityStatus) async {
    try {
      var doctypeCachingService = locator.get<DoctypeCachingService>();
      // add api call and if its 200 then only cache
      var statusCode = await locator.get<CommonService>().checkSessionExpired();
      // session not expired cache data
      if (statusCode == 200) {
        setState(ViewState.busy);
        await Future.wait([
          doctypeCachingService.cacheDoctype(
              Strings.itemGroupTree, 7, connectivityStatus),
          doctypeCachingService.cacheDoctype(
              Strings.salesOrder, 30, connectivityStatus),
        ]);
        setState(ViewState.idle);
        await Future.wait([
          doctypeCachingService.cacheDoctype(
              Strings.customerNameList, 7, connectivityStatus),
          doctypeCachingService.cacheDoctype(
              Strings.item, 7, connectivityStatus),
          doctypeCachingService.cacheDoctype(
              Strings.bin, 1, connectivityStatus),
          doctypeCachingService.cacheDoctype(
              Strings.files, 7, connectivityStatus),
          // cacheDoctype(Strings.itemPrice, 7, context),
          doctypeCachingService.cacheDoctype(
              Strings.customer, 7, connectivityStatus),
          doctypeCachingService.cacheDoctype(
              Strings.currency, 30, connectivityStatus),
        ]);
      }
      // session is expired dont cache
      else if (statusCode == 403) {
        locator.get<StorageService>().removeLoggedIn =
            PreferenceVariables.loggedIn;
        await locator.get<NavigationService>().navigateTo(loginViewRoute);
      } else {}
    } catch (e) {
      exception(e, '', 'checkDoctypeCachedOrNot');
    } finally {
      setState(ViewState.idle);
    }
  }

  Future cachePriceListAndItemPrice(int cacheDays, BuildContext context) async {
    setState(ViewState.busy);
    var pricelist = <String>[];
    var custPriceList = locator.get<StorageService>().priceList;
    if (custPriceList.isNotEmpty) {
      // fetch pricelist from cache
      var data = locator.get<OfflineStorage>().getItem(Strings.priceList);
      if (data['data'] == null) {
        pricelist.add(custPriceList);
        await locator
            .get<OfflineStorage>()
            .putItem(Strings.priceList, pricelist);
        await cacheItemPrice(Strings.itemPrice, pricelist, context);
      }
      // pricelist contains data
      else {
        if (data['timestamp'] != null) {
          var timestamp = data['timestamp'] as DateTime;
          var timeNow = DateTime.now();
          var difference = timeNow.difference(timestamp);
          if (difference.inDays > cacheDays) {
            // cache doctype
            await locator
                .get<OfflineStorage>()
                .putItem(Strings.priceList, [custPriceList]);
            await cacheItemPrice(Strings.itemPrice, [custPriceList], context);
          }
          // data is not null and we cannot cache new data check if pricelist contains customer pricelist
          else {
            var data = locator.get<OfflineStorage>().getItem(Strings.priceList);
            var pl = data['data'] as List<String>;
            if (!pl.contains(custPriceList)) {
              pl.add(custPriceList);
              // cache pricelist with customer pricelist
              await locator
                  .get<OfflineStorage>()
                  .putItem(Strings.priceList, pl);
              // append item price with customer pricelist and cache it
              await appendAndCacheItemPrice(
                  Strings.itemPrice, [custPriceList], context);
            }
          }
        }
      }
    }
    setState(ViewState.idle);
  }

  Future cacheItemPrice(
      String doctype, List<String> pricelist, BuildContext context) async {
    setState(ViewState.busy);
    try {
      var itemPrices = <ItemPrice>[];
      // cache itemprices
      for (var i = 0; i < pricelist.length; i++) {
        var itemprice = await getItemPricesFromPricelist(pricelist[i]);
        itemPrices.addAll(itemprice);
      }
      await locator.get<OfflineStorage>().putItem(doctype,
          jsonEncode(ItemPriceList(itemPriceList: itemPrices).toJson()));
      showToast('${Strings.itemPrice} synced ', context: context);
    } catch (e) {
      exception(e, '', 'cacheItemPrice');
    } finally {
      setState(ViewState.idle);
    }
    setState(ViewState.idle);
    notifyListeners();
  }

  Future appendAndCacheItemPrice(
      String doctype, List<String> pricelist, BuildContext context) async {
    setState(ViewState.busy);
    try {
      var itemPrices = <ItemPrice>[];
      var data = await locator.get<OfflineStorage>().getItem(doctype);
      itemPrices = data['data'] as List<ItemPrice>;
      // cache itemprices
      for (var i = 0; i < pricelist.length; i++) {
        var itemprice = await getItemPricesFromPricelist(pricelist[i]);
        itemPrices.addAll(itemprice);
      }
      await locator.get<OfflineStorage>().putItem(doctype,
          jsonEncode(ItemPriceList(itemPriceList: itemPrices).toJson()));
      showSnackBar('${Strings.itemPrice} synced ', context);
    } catch (e) {
      exception(e, '', 'appendAndCacheItemPrice');
    } finally {
      setState(ViewState.idle);
    }

    setState(ViewState.idle);
    notifyListeners();
  }

  Future<List<ItemPrice>> getItemPricesFromPricelist(String? pricelist) async {
    var list = [];
    var itemPriceList = <ItemPrice>[];
    var url = '/api/resource/Item Price';
    // var custpricelist = await getPriceList();
    // var queryParams = {
    //   'fields':
    //       '["name","item_code","item_name","packing_unit","price_list","customer","currency","price_list_rate","uom"]',
    //   'limit_page_length': '*',
    //   'filters': '[["Item Price","price_list","=","$pricelist"]]',
    // };
    var queryParams1 = {
      'fields': '["name"]',
      'limit_page_length': '*',
      'filters': '[["Item Price","price_list","=","$pricelist"]]',
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams1,
      );
      if (response?.statusCode == 200) {
        var data = response?.data;
        list = data['data'];
        var ip = <ItemPrice>[];
        for (var listJson in list) {
          ip.add(ItemPrice.fromJson(listJson));
        }

        for (var i = 0; i < ip.length; i++) {
          var ipData =
              await getItemPriceFromName(Strings.itemPrice, ip[i].name ?? '');
          itemPriceList.add(ipData);
        }
        return itemPriceList;
      }
    } catch (e) {
      exception(e, url, 'getItemPricesFromPricelist');
    }
    return itemPriceList;
  }

  Future<ItemPrice> getItemPriceFromName(String doctype, String name) async {
    final cu = doctypeDetailUrl(doctype, name);
    try {
      final response = await DioHelper.dio?.get(cu);
      if (response?.statusCode == 200) {
        var data = response?.data;
        var so = ItemPrice.fromJson(data['data']);
        return so;
      }
    } catch (e) {
      exception(e, cu, 'getItemPriceFromName');
    }
    return ItemPrice();
  }

  Future getCustomerFromEmail(String email) async {
    setState(ViewState.busy);
    var customerData = locator.get<OfflineStorage>().getItem(Strings.customer);
    if (customerData['data'] != null) {
      customer = await locator
          .get<CustomerServices>()
          .getCustomerFromEmailIdFromCache(email);
    } else {
      customer =
          await locator.get<CustomerServices>().getCustomerFromEmailId(email);
    }

    // print('Customer');
    // print(customer.name);
    notifyListeners();
    setState(ViewState.idle);
  }

  void setPriceList() async {
    if (customer.defaultPriceList != null) {
      locator.get<StorageService>().priceList = customer.defaultPriceList!;
    }
  }

  Future getCustomerFromCustomerName(String name) async {
    var customerData = locator.get<OfflineStorage>().getItem(Strings.customer);
    if (customerData['data'] != null) {
      customer = await locator
          .get<CustomerServices>()
          .getCustomerFromCustomerNameFromCache(name);
    } else {
      customer =
          await locator.get<CustomerServices>().getCustomerFromName(name);
    }
    notifyListeners();
  }

  Future storeCatalogModelData() async {
    //TODO:break
    var model = CustomerAndPriceListConfigurationModel(
      customer: customer.toJson(),
      priceList: customer.defaultPriceList,
      isUserCustomer: locator.get<StorageService>().isUserCustomer,
    );
    await locator.get<OfflineStorage>().putItem('catalogue', model.toJson());
  }

  //Below this Items View Code

  // check if item exists in cart
  bool existsInCart(List<Cart> state, ItemsModel item) {
    var found = false;
    for (var element in state) {
      if (element.itemCode == item.itemCode) found = true;
    }
    return found;
  }

  void setCatalogItemIndex(int index) {
    // set this to false as add to card visible implementation was throwing exception
    // using this add to cart when its setting in background its ui is hidden by isQuantityControllerInitialized
    // and when its initialized its ui becomes visible
    isQuantityControllerInitialized = false;
    if (itemList.isNotEmpty) {
      catalogItemIndex = index;
      sliderValue = index.toDouble();
    }
    updateQuantityControllerCatalogViewText();
    // catalogueViewQuantity();
    getProduct();
    notifyListeners();
  }

  void catalogueViewQuantity() {
    // set item quantity
    if (cartItems != null) {
      for (var i = 0; i < cartItems!.length; i++) {
        if (cartItems?[i].itemCode == itemList[catalogItemIndex].itemCode) {
          catalogueItemQuantity = cartItems![i].quantity;
        }
      }
    }
    notifyListeners();
  }

  void initCarouselData() {
    current.clear();
    for (var i = 0; i < itemList.length; i++) {
      controller.add(CarouselSliderController());
      current.add(0);
    }
    // for (var data in current) {
    //   print('Current $data');
    // }
    notifyListeners();
  }

  Future getProducts() async {
    productList = await getProductList();
    notifyListeners();
  }

  Future getProduct() async {
    if (itemList.isNotEmpty) {
      product = productList.firstWhere(
          (element) => element.itemCode == itemList[catalogItemIndex].itemCode);
    }
    notifyListeners();
  }

  Future<List<Product>> getProductList() async {
    var data = locator.get<OfflineStorage>().getItem(Strings.item);
    // cached data is there then show cached item
    if (data['data'] != null) {
      var itemdata = jsonDecode(data['data']);
      var productList = ProductList.fromJson(itemdata);
      if (productList.productList != null) {
        var list = productList.productList!;
        return list;
      }
      // product list is null
      else {
        return [];
      }
    }
    // load from api
    else {
      return [];
    }
  }

  Future add(ItemsModel item, BuildContext context) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = Cart(
        id: item.itemCode,
        itemName: item.itemName,
        quantity: item.quantity,
        itemCode: item.itemCode,
        rate: item.price,
        imageUrl: (item.images == null || item.images?.isEmpty == true)
            ? item.imageUrl
            : item.images![0].fileUrl);

    if (cartPageViewModel.existsInCart(cartPageViewModel.items, cartItem)) {
      updateCartItems();
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      //Increment quantity
      await cartPageViewModel.increment(index, context);
    } else {
      await cartPageViewModel.add(cartItem, context);
    }
    await updateCartItems();
    await cartPageViewModel.initQuantityController();
  }

  Future remove(ItemsModel item, BuildContext context, int itemQuantity) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    final cartItem = Cart(
        id: item.itemCode,
        itemName: item.itemName,
        quantity: item.quantity,
        itemCode: item.itemCode,
        rate: item.price,
        imageUrl: (item.images == null || item.images?.isEmpty == true)
            ? item.imageUrl
            : item.images![0].fileUrl);

    // when quantity reaches to 1 remove item from cart
    if (itemQuantity == 1) {
      // remove quantity from cart

      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      await cartPageViewModel.remove(index, context);
    }
    // decrement quantity until quantity reaches to 1
    else {
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      await cartPageViewModel.decrement(index, context);
    }
    await updateCartItems();
    await cartPageViewModel.initQuantityController();
    // await model.getCartItems();
  }

  void init() {
    setState(ViewState.busy);

    isSelected.clear();
    attributeSelected = false;
    notifyListeners();
    setState(ViewState.idle);
  }

  void setCategorySelected(String? category, String? image) {
    categorySelected = category;
    categorySelectedImage = image;
    notifyListeners();
  }

  Future clearQuantityController() async {
    quantityControllerList.clear();
    notifyListeners();
  }

  Future initQuantityController() async {
    setState(ViewState.busy);
    isQuantityControllerInitialized = false;
    var cartPageViewModel = locator.get<CartPageViewModel>();
    quantityControllerList.clear();

    if (itemList.isNotEmpty) {
      //init controller & add to cart visible
      for (var i = 0; i < itemList.length; i++) {
        quantityControllerList.add(QuantityControllerModel(
            itemList[i].itemCode, TextEditingController()));
      }
      //set text to quantity controller
      for (var i = 0; i < itemList.length; i++) {
        var item = itemList[i];
        var cartItemCodeList =
            cartPageViewModel.items.map((e) => e.itemCode).toList();
        // if exists in cart then fetch cart quantity and set it to field
        if (cartItemCodeList.contains(item.itemCode)) {
          var cartItem = cartPageViewModel.items
              .firstWhere((element) => element.itemCode == item.itemCode);
          var index = cartPageViewModel.items.indexOf(cartItem);
          var qty = cartPageViewModel.items[index].quantity;
          quantityControllerList[i].controller?.text = qty.toString();
        }
        //if doenst exist in cart init to 0
        else {
          quantityControllerList[i].controller?.text = 0.toString();
        }
      }
    }
    isQuantityControllerInitialized = true;
    notifyListeners();
    setState(ViewState.idle);
  }

  void incrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val + 1;
    quantityControllerList[index].controller?.text = val.toString();
    notifyListeners();
  }

  void decrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val - 1;
    quantityControllerList[index].controller?.text = val.toString();
    notifyListeners();
  }

  void updateQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val;
    quantityControllerList[index].controller?.text = val.toString();
    notifyListeners();
  }

  void updateQuantityControllerCatalogViewText() {
    var cartItemsList = cartItems;
    if (itemList.isNotEmpty) {
      var item = itemList[catalogItemIndex];
      if (cartItemsList != null) {
        if (cartItemsList.isNotEmpty) {
          if (existsInCart(cartItems!, item)) {
            var cartItem = cartItemsList
                .firstWhere((element) => element.itemCode == item.itemCode);
            quantityControllerCatalogueView.text = cartItem.quantity.toString();
          }
        }
      }
    }
  }

  // set quantity at index
  Future setQty(int index, String value, BuildContext context) async {
    // quantityControllerList[index].text = value;
    // itemsList[index].quantity = int.parse(value);
    // update cart item
    var item = itemList[index];

    var cartPageViewModel = locator.get<CartPageViewModel>();
    var cartItemItemCodes =
        cartPageViewModel.items.map((e) => e.itemCode).toList();
    // if cart contains item then update cart
    if (cartItemItemCodes.contains(item.itemCode)) {
      var cartItem = cartPageViewModel.items
          .firstWhere((element) => element.itemCode == item.itemCode);
      var cartItemIndex = cartPageViewModel.items.indexOf(cartItem);
      cartPageViewModel.setQty(cartItemIndex, value, context);
    }
    // if cart doesnt contain item then add that item to cart
    else {
      await cartPageViewModel.add(
          Cart(
              id: item.itemCode,
              itemName: item.itemName,
              quantity: int.parse(value),
              itemCode: item.itemCode,
              rate: item.price,
              imageUrl: item.imageUrl),
          context);
    }

    await cartPageViewModel.initQuantityController();

    notifyListeners();
  }

  Future applyFilter(List<String?> selectedTagsList) async {
    itemList = itemCopyList;
    var selectedTags = selectedTagsList;
    if (selectedTags.isNotEmpty) {
      // filter down list to only items which have tags in them
      var itemWithTags = itemCopyList.where((item) {
        if (item.itemTags != null) {
          if (item.itemTags!.length > 0) {
            return true;
          }
        }
        return false;
      });
      // show items based on selected tags and filter list accordingly

      var listItemFiltered = itemWithTags.where(
        (element) {
          for (var i = 0; i < selectedTags.length; i++) {
            var tag = selectedTags[i];
            if (element.itemTags != null) {
              for (var j = 0; j < element.itemTags!.length; j++) {
                var tagInItem = element.itemTags?[j];
                if (tag == tagInItem?.tagName) {
                  return true;
                }
              }
            }
          }
          return false;
        },
      );
      // update list
      var newList = <ItemsModel>[];
      listItemFiltered.forEach(
        (listItem) {
          if (!newList.contains(listItem)) {
            newList.add(listItem);
          }
        },
      );
      itemList = newList;
    }
    // display original list when none of tag is selected
    else {
      itemList = itemCopyList;
    }

    notifyListeners();
  }

  Future clearFilter() async {
    itemList = itemCopyList;
    notifyListeners();
  }

  Future refresh() async {
    await Future.delayed(const Duration(milliseconds: 50));
    // update cart
    notifyListeners();
  }

  Future reCacheData(ItemsViewModel model, BuildContext context) async {
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    // cache doctypes
    await locator
        .get<DoctypeCachingService>()
        .reCacheDoctypes(connectivityStatus);
    await model.cachePriceListAndItemPrice(7, context);
    await Future.wait([
      model.itemGroupListWithoutReturn(context),
    ]);
    await model.getStockActualQtyList();
  }

  void setViewType(ViewTypes view) async {
    viewType = view;
    notifyListeners();
  }

  void setWeight1(String value) {
    weight1 = value;
    notifyListeners();
  }

  void setWeight2(String value) {
    weight2 = value;
    notifyListeners();
  }

  void clearItemList() {
    itemList = itemCopyList;
    item = '';
    notifyListeners();
  }

  Future<List<ItemGroupModel>> itemGroupList(BuildContext context) async {
    // setState(ViewState.busy);
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    itemGroups =
        await locator.get<ItemsService>().getItemGroupList(connectivityStatus);
    // setState(ViewState.idle);
    // notifyListeners();
    return itemGroups;
  }

  Future itemGroupListWithoutReturn(BuildContext context) async {
    setState(ViewState.busy);
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);
    itemGroups =
        await locator.get<ItemsService>().getItemGroupList(connectivityStatus);
    setState(ViewState.idle);
    notifyListeners();
    return itemGroups;
  }

  Future<dynamic> navigateToItemDetailPage(
      ItemsModel item, BuildContext context) async {
    await locator
        .get<NavigationService>()
        .navigateTo(itemsDetailViewRoute, arguments: item.itemCode);
  }

  Future navigateToSearchPage(bool searchText, BuildContext context) async {
    var itemListForSearch = <String>[];
    // var list = await locator.get<ItemsService>().getAllItemsList();
    //TODO:Issue
    for (var item in itemCopyList) {
      itemListForSearch.add(item.itemName!);
    }
    item = await locator
        .get<NavigationService>()
        .navigateTo(searchViewRoute, arguments: itemsViewRoute);

    if (item.isNotEmpty) {
      itemList = itemCopyList
          .where((i) => i.itemName!.toLowerCase().contains(item))
          .toList();
    }
    notifyListeners();
  }

  Future<int> getIndexOfCartItem(ItemsModel item) async {
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          cartItems = cart.cartList!;
          for (var i = 0; i < cartItems!.length; i++) {
            if (item.itemCode == cartItems?[i].itemCode) {
              return cartItems![i].quantity;
            }
          }
        }
      }
    }
    return 0;
  }

  Future getCartItems() async {
    //from hive
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          cartItems = cart.cartList!;
        }
      }

      notifyListeners();
    }
  }

  updateCartItems() {
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          cartItems = cart.cartList!;
        }
      }
      notifyListeners();
    }
  }

  Future getItem(String item) async {
    itemList = await locator.get<ItemsService>().getItem(item);
    notifyListeners();
  }

  Future getAllItems() async {
    setState(ViewState.busy);
    itemList.clear();
    itemList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedItemItemsModelData();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemCopyList = itemList;
    getPrices();
    setState(ViewState.idle);
    await Future.delayed(const Duration(milliseconds: 5));
    notifyListeners();
    // getPrices();
  }

  Future getItemListFromItemName(
      String itemName, ConnectivityStatus connectivityStatus) async {
    setState(ViewState.busy);
    itemList.clear();
    itemList = await locator
        .get<ItemsService>()
        .getItemsListFromItemName(itemName, connectivityStatus);

    // itemList.sort((a, b) => a.itemName!.compareTo(b.itemName!));
    // print('P : ' + itemList[1].price.toString());

    // itemList.forEach((item) async {
    //   double price = await locator.get<ItemsService>().getPrice(item.itemCode!);
    //   int index = itemList.indexOf(item);
    //   itemList[index].price = price;

    //   // print('Price is ' + itemList[index].price.toString());
    // });

    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    // print(itemList.length);
    itemCopyList = itemList;
    getPrices();
    setState(ViewState.idle);
    await Future.delayed(const Duration(milliseconds: 5));
    notifyListeners();
    // getPrices();
  }

  Future getItemListFromItemCode(
      String itemCode, ConnectivityStatus connectivityStatus) async {
    setState(ViewState.busy);
    itemList.clear();
    itemList = await locator
        .get<ItemsService>()
        .getItemsListFromItemCode(itemCode, connectivityStatus);

    // itemList.sort((a, b) => a.itemName!.compareTo(b.itemName!));
    // print('P : ' + itemList[1].price.toString());

    // itemList.forEach((item) async {
    //   double price = await locator.get<ItemsService>().getPrice(item.itemCode!);
    //   int index = itemList.indexOf(item);
    //   itemList[index].price = price;

    //   // print('Price is ' + itemList[index].price.toString());
    // });

    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    // print(itemList.length);
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemCopyList = itemList;
    getPrices();
    setState(ViewState.idle);
    await Future.delayed(const Duration(milliseconds: 5));
    notifyListeners();
    // getPrices();
  }

  Future getSpecificItemFromItemName(
      String searchText, ConnectivityStatus connectivityStatus) async {
    // List<ItemsModel> list = [];
    setState(ViewState.busy);
    itemList.clear();
    itemList = await locator
        .get<ItemsService>()
        .getSpecificItemDataFromItemName(searchText, connectivityStatus);
    // print('P : ' + itemList[1].price.toString());
    // itemList.sort((a, b) => a.itemName!.compareTo(b.itemName!));
    for (var item in itemList) {
      double price = await locator.get<ItemsService>().getPrice(item.itemCode!);
      var index = itemList.indexOf(item);
      itemList[index].price = price;
      // print('Price is ' + itemList[index].price.toString());
    }
    //TODO
    // add item when hasVariants is 1 and variantOf is null
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemList = itemList;
    // print(itemList.length);
    itemCopyList = itemList;
    setState(ViewState.idle);
    await Future.delayed(const Duration(milliseconds: 5));
    notifyListeners();
  }

  Future getSpecificItemFromItemCode(
      String searchText, ConnectivityStatus connectivityStatus) async {
    // List<ItemsModel> list = [];
    setState(ViewState.busy);
    itemList.clear();
    itemList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedItemItemsModelData();
    itemList = itemList.where((e) => (e.itemCode == searchText)).toList();
    // itemList = await locator
    //     .get<ItemsService>()
    //     .getSpecificItemDataFromItemCode(searchText, connectivityStatus);
    // print('P : ' + itemList[1].price.toString());
    // itemList.sort((a, b) => a.itemName!.compareTo(b.itemName!));
    for (var item in itemList) {
      double price = await locator.get<ItemsService>().getPrice(item.itemCode!);
      var index = itemList.indexOf(item);
      itemList[index].price = price;
      // print('Price is ' + itemList[index].price.toString());
    }
    //TODO
    // add item when hasVariants is 1 and variantOf is null
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemList = itemList;
    // print(itemList.length);
    itemCopyList = itemList;
    setState(ViewState.idle);
    await Future.delayed(const Duration(milliseconds: 5));
    notifyListeners();
  }

  Future<List<FileModelOrderIT>> getImages(
      String? name, ConnectivityStatus connectivityStatus) async {
    var files = <FileModelOrderIT>[];
    var data = locator.get<OfflineStorage>().getItem(Strings.files);
    // cached data is there then show cached files
    if (data['data'] != null) {
      var filedata = jsonDecode(data['data']);
      var fileslist = FilesList.fromJson(filedata);
      if (fileslist.filesList != null) {
        var list = fileslist.filesList!;
        files = list.where((file) => file.attachedToName == name).toList();
        return files;
      }
      // files list is null
      else {
        return [];
      }
    }

    // load from api
    else {
      files = await locator.get<ItemsService>().getImages(name);
      return files;
    }
  }

  Future getItemGroupData(String itemGroupName, BuildContext context) async {
    // List<ItemsModel> c = [];
    setState(ViewState.busy);
    itemList.clear();
    var connectivityStatus =
        Provider.of<ConnectivityStatus>(context, listen: false);

    itemList = await locator
        .get<ItemsService>()
        .getItemFromItemGroup(itemGroupName, connectivityStatus);
    // itemList.sort((a, b) => a.itemName!.compareTo(b.itemName!));
    // itemList.forEach((item) async {
    //   double price = locator.get<ItemsService>().getPrice(item.itemCode!);
    //   int index = itemList.indexOf(item);
    //   itemList[index].price = price;
    // });
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    // print(itemList.length);
    // below code hides template
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemCopyList = itemList;
    getPrices();
    setState(ViewState.idle);
    await Future.delayed(const Duration(milliseconds: 5));
    notifyListeners();
  }

  // return type is not added intentionally to load list data without waiting for prices to fetch
  getPrices() async {
    for (var i in itemList) {
      double price = await locator.get<ItemsService>().getPrice(i.itemCode!);
      // print(i.hasVariants);
      var index = itemList.indexOf(i);

      itemList[index].price = price;
    }
    //TODO
    // add item when hasVariants is 1 and variantOf is null
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemList = itemList;
    notifyListeners();
  }

  Future resetAll() async {
    // itemList = await locator.get<ItemsService>().getItemsList();
    // sortByItemNameAsc(SortBy.itemNameAsc);
    itemList = itemCopyList;
    weight1 = '';
    weight2 = '';
    notifyListeners();
  }

  Future sortByItemCodeAscFunc() async {
    itemList = itemCopyList;
    //TODO
    // add item when hasVariants is 1 and variantOf is null
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemList = itemList;
    itemList.sort((a, b) => a.itemCode!.compareTo(b.itemCode!));
    // print('itemcode asc');
    notifyListeners();
  }

  Future sortByItemCodeDescFunc() async {
    itemList = itemCopyList;
    //TODO
    // add item when hasVariants is 1 and variantOf is null
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemList = itemList;
    itemList.sort((a, b) => a.itemCode!.compareTo(b.itemCode!));
    itemList = itemList.reversed.toList();
    // print('itemcode desc');
    notifyListeners();
  }

  Future sortByItemNameAscFunc() async {
    itemList = itemCopyList;
    //TODO
    // add item when hasVariants is 1 and variantOf is null
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemList = itemList;
    itemList.sort((a, b) => a.itemName!.compareTo(b.itemName!));
    // print('itemname asc');
    notifyListeners();
  }

  Future sortByItemNameDescFunc() async {
    itemList = itemCopyList;
    //TODO
    // add item when hasVariants is 1 and variantOf is null
    // itemList = itemList
    //     .where((e) =>
    //         ((e.price != 0 || e.hasVariants == 1) && (e.variantOf == null)))
    //     .toList();
    itemList = itemList.where((e) => (e.variantOf == null)).toList();
    itemList = itemList;
    itemList.sort((a, b) => a.itemName!.compareTo(b.itemName!));
    itemList = itemList.reversed.toList();
    // print('itemname desc');
    notifyListeners();
  }

  void getItemBrandData(String brandName) async {
    itemList.clear();
    itemList = await locator.get<ItemsService>().getItemBrandData(brandName);
    notifyListeners();
  }

  void pageChangedCallback(int itemIndex, int index) {
    current[itemIndex] = index;
    notifyListeners();
  }
}

class QuantityControllerModel {
  final String? id;
  final TextEditingController? controller;

  QuantityControllerModel(this.id, this.controller);
}
