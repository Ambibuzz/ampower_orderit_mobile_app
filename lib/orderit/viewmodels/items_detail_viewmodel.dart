import 'dart:convert';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:orderit/common/models/item_price_model.dart';
import 'package:orderit/common/models/stock_actual_qty.dart';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/common/services/stock_actual_qty_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/cart.dart';
import 'package:orderit/orderit/models/file_model.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/orderit/services/items_api_service.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/orderit/viewmodels/cart_page_viewmodel.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/util/apiurls.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/enums.dart';
import 'package:orderit/base_viewmodel.dart';
import 'package:flutter/material.dart';

class ItemsDetailViewModel extends BaseViewModel {
  Product product = Product();
  Product ogProduct = Product();

  List<Cart> items = [];
  // int quantity = 1;
  bool itemExistsInCart = false;
  int index = 0;
  bool productDescriptionTileExpanded = true;
  double totalqty = 0;

  String? ogitemcode;
  List<Product> productsFromVariants = [];
  List<Product> p1 = [];
  double price = 0;

  List<String?> attributesList = [];
  List<String?> attributeDropdownList = [];
  String? dropdownAttributeSelected;
  Map<String, dynamic> attributesMap = {};
  List<bool> isSelected = [];
  List<bool> isSelectedImage = [];
  int falseCount = 0;
  bool attributeSelected = false;
  bool itemFound = false;
  int newQty = 1;
  int clickedImageIndex = 0;
  var files = <FileModelOrderIT>[];
  List<TextEditingController> quantityControllerList =
      <TextEditingController>[];
  List<Cart>? cartItems = [];
  List<ItemPrice> itemPriceList = [];
  //Carousel
  final controller = CarouselSliderController();
  int current = 0;
  var itemApiServiceLocator = locator.get<ItemsService>();
  var quantityController = TextEditingController();
  double? stockActualQty = 0.0;
  var stockActualQtyList = <StockActualQty>[];

  Future getStockActualQtyList() async {
    stockActualQtyList =
        await locator.get<DoctypeCachingService>().getStockActualQtyList();
    notifyListeners();
  }

  void getStockActualQty(String? itemCode) {
    stockActualQty = locator
        .get<StockActualQtyService>()
        .getStockActualQty(itemCode, stockActualQtyList);
  }

  Future getItemPrices() async {
    itemPriceList = await locator
        .get<FetchCachedDoctypeService>()
        .fetchCachedItemPriceData();
    notifyListeners();
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
      await locator.get<ItemsViewModel>().updateCartItems();
      var cartItemObj = cartPageViewModel.items
          .firstWhere((e) => e.itemCode == item.itemCode);
      var index = cartPageViewModel.items.indexOf(cartItemObj);
      //Increment quantity
      await cartPageViewModel.increment(index, context);
    } else {
      await cartPageViewModel.add(cartItem, context);
    }
    updateCartItems();
    await locator.get<ItemsViewModel>().updateCartItems();
    await cartPageViewModel.initQuantityController();
    notifyListeners();
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
    updateCartItems();
    await locator.get<ItemsViewModel>().updateCartItems();
    await cartPageViewModel.initQuantityController();
  }

  Future removeFromCart(ItemsModel item, BuildContext context) async {
    var cartPageViewModel = locator.get<CartPageViewModel>();
    // remove quantity from cart
    var cartItemObj =
        cartPageViewModel.items.firstWhere((e) => e.itemCode == item.itemCode);
    var index = cartPageViewModel.items.indexOf(cartItemObj);
    await cartPageViewModel.remove(index, context);

    updateCartItems();
    await locator.get<ItemsViewModel>().updateCartItems();
    await cartPageViewModel.initQuantityController();
  }

  void incrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val + 1;
    quantityControllerList[index].text = val.toString();
    notifyListeners();
  }

  void decrementQuantityControllerText(int index, String value) {
    var val = int.parse(value);
    val = val - 1;
    quantityControllerList[index].text = val.toString();
    notifyListeners();
  }

  Future refresh() async {
    await Future.delayed(const Duration(milliseconds: 5));
    notifyListeners();
  }

  Future getAttributesDropdownList() async {
    attributeDropdownList.clear();
    if (productsFromVariants.isNotEmpty) {
      for (var i = 0; i < productsFromVariants.length; i++) {
        var item = productsFromVariants[i];
        var attribute = '';
        // item.attributes?.forEach((a) {
        //   attribute += '${a.attribute}:${a.attributeValue}';
        // });
        attributeDropdownList.add(attribute);
      }
      await setIsSelected(1);
      setDropdownAttribute(attributeDropdownList[0]);
    }
    notifyListeners();
  }

  void setDropdownAttribute(String? value) {
    dropdownAttributeSelected = value;
    notifyListeners();
  }

  void pageChangedCallback(int index) {
    current = index;
    notifyListeners();
  }

  void updateQuantityController() {
    updateCartItems();

    if (itemInCart()) {
      quantityController.text = items[index].quantity.toString();
    } else {
      quantityController.text = 1.toString();
    }
    notifyListeners();
  }

  bool itemInCart() {
    for (var cartItem in items) {
      if (cartItem.itemCode == product.itemCode) {
        return true;
      }
    }
    return false;
  }

  Future init() async {
    setState(ViewState.busy);
    isSelected.clear();
    isSelectedImage.clear();
    attributeSelected = false;
    clickedImageIndex = 0;
    productsFromVariants.clear();
    attributeDropdownList.clear();
    setItemInCartValue(false);
    notifyListeners();
    setState(ViewState.idle);
  }

  Future getImages(String? name) async {
    var data = locator.get<OfflineStorage>().getItem(Strings.files);
    // cached data is there then show cached files
    if (data['data'] != null) {
      var filedata = jsonDecode(data['data']);
      var fileslist = FilesList.fromJson(filedata);
      if (fileslist.filesList != null) {
        var list = fileslist.filesList!;
        files = list.where((file) => file.attachedToName == name).toList();
      }
      // files list is null
      else {}
    }
    // load from api
    else {
      files = await itemApiServiceLocator.getImages(name);
    }
    notifyListeners();
  }

  void setImageIndex(int index) {
    clickedImageIndex = index;
    notifyListeners();
  }

  Future setIsSelectedImage(int i) async {
    for (var j = 0; j < isSelectedImage.length; j++) {
      if (i == j) {
        isSelectedImage[j] = true;
      } else {
        isSelectedImage[j] = false;
      }
    }
    notifyListeners();
  }

  Future setIsSelected(int i) async {
    falseCount = 0;
    for (var a in isSelected) {
      var ind = isSelected.indexOf(a);
      if (ind != i) {
        isSelected[ind] = false;
      }
    }
    isSelected[i] = !isSelected[i];
    double price = await locator
        .get<ItemsService>()
        .getPrice(productsFromVariants[i].itemCode!);
    for (var e in isSelected) {
      if (e == false) {
        falseCount++;
      }
    }
    if (isSelected[i] == true) {
      attributeSelected = true;
      product.image = productsFromVariants[i].image;
      product.itemCode = productsFromVariants[i].itemCode;
      product.itemGroup = productsFromVariants[i].itemGroup;
      product.itemName = productsFromVariants[i].itemName;

      product.stockUom = productsFromVariants[i].stockUom;
      product.gstHsnCode = productsFromVariants[i].gstHsnCode;
      product.description = productsFromVariants[i].description;
      product.brand = productsFromVariants[i].brand;

      product.shelfLifeInDays = productsFromVariants[i].shelfLifeInDays;
      product.warrantyPeriod = productsFromVariants[i].warrantyPeriod;
      product.hasVariants = productsFromVariants[i].hasVariants;

      // get images for selected variant item
      await getImages(productsFromVariants[i].name);

      var index = getIndexOfItem(productsFromVariants[i]);
      if (!itemFound) {
        setItemInCartValue(false);
      }
      await setIndex(index);
    } else {
      attributeSelected = false;
      if (ogitemcode != null) {
        var data = locator.get<OfflineStorage>().getItem(Strings.item);
        // cached data is there then show cached item
        if (data['data'] != null) {
          var itemdata = jsonDecode(data['data']);
          var productList = ProductList.fromJson(itemdata);
          if (productList.productList != null) {
            var list = productList.productList!;
            product = list.firstWhere((item) => item.itemCode == ogitemcode);
          }
          // product list is null
          else {}
        }
        // load from api
        else {
          product = await locator
              .get<ItemsService>()
              .getData(itemDataUrl(ogitemcode!));
        }
        // get images for original item
        await getImages(product.name);
      }

      var index = getIndexOfItem(product);
      await setIndex(index);
    }
    // update cart items and initialize quantity controller after a variant is selected or deselected
    updateCartItems();
    await locator.get<CartPageViewModel>().initQuantityController();
    notifyListeners();
  }

  int getIndexOfItem(Product product) {
    var index = 0;
    itemFound = false;
    for (var cartItem in items) {
      if (cartItem.itemCode == product.itemCode) {
        itemFound = true;
        index = items.indexOf(cartItem);
        // setQuantity(cartItem.quantity);
        setItemInCartValue(true);
      }
    }
    notifyListeners();
    return index;
  }

  int getIndexOfItemWrtCart() {
    final cartPageModel = locator.get<CartPageViewModel>();
    var index = 0;

    for (var cartItem in cartPageModel.items) {
      if (cartItem.itemCode == product.itemCode) {
        index = cartPageModel.items.indexOf(cartItem);
        // setQuantity(cartItem.quantity);
        setItemInCartValue(true);
      }
    }

    return index;
  }

  void onExpansionChanged(bool value) {
    productDescriptionTileExpanded = value;
    notifyListeners();
  }

  void setItemInCartValue(bool val) {
    itemExistsInCart = val;
    notifyListeners();
  }

  Future setIndex(int v) async {
    index = v;
    notifyListeners();
  }

  Future resetIndex() async {
    index = 0;
    notifyListeners();
  }

  Future getProduct(String? itemcode) async {
    setState(ViewState.busy);
    ogitemcode = '';
    var data = locator.get<OfflineStorage>().getItem(Strings.item);
    // cached data is there then show cached item
    if (data['data'] != null) {
      var itemdata = jsonDecode(data['data']);
      var productList = ProductList.fromJson(itemdata);
      if (productList.productList != null) {
        var list = productList.productList!;
        product = list.firstWhere((item) => item.itemCode == itemcode);
        ogProduct = product;
      }
      // product list is null
      else {}
    }
    // load from api
    else {
      product =
          await locator.get<ItemsService>().getData(itemDataUrl(itemcode!));
      ogProduct =
          await locator.get<ItemsService>().getData(itemDataUrl(itemcode));
    }
    ogitemcode = product.itemCode;
    // get images
    await getImages(product.name);
    // get price
    price = await locator.get<ItemsService>().getPrice(itemcode!);
    notifyListeners();
    setState(ViewState.idle);
  }

  Future getCartItems() async {
    //from hive
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          items = cart.cartList!;
        }
      }
      notifyListeners();
    }
  }

  // Flow of fetching variants for an item
  // Fetch item where variant_of == itemcode
  // after that iterate through each item fetched above and get attribute list obtained through item.attributes
  Future getVariants() async {
    // setState(ViewState.busy);

    if (product.itemCode != null) {
      p1 = await locator
          .get<ItemsService>()
          .getVariantsFromItemCode(product.itemCode);
      await getAttributesList();
    } else {}
    notifyListeners();
    // setState(ViewState.busy);
  }

  Future getAttributesList() async {
    // setState(ViewState.busy);
    productsFromVariants.clear();
    var data = locator.get<OfflineStorage>().getItem(Strings.item);
    for (var i in p1) {
      isSelected.add(false);
      // cached data is there then show cached item
      if (data['data'] != null) {
        var itemdata = jsonDecode(data['data']);
        var productList = ProductList.fromJson(itemdata);
        if (productList.productList != null) {
          var list = productList.productList!;
          var p = list.firstWhere((item) => item.itemCode == i.itemCode);
          productsFromVariants.add(p);
        }
        // product list is null
        else {}
      }
      // load from api
      else {
        var p =
            await locator.get<ItemsService>().getData(itemDataUrl(i.itemCode!));
        productsFromVariants.add(p);
      }
    }
    notifyListeners();
    // setState(ViewState.busy);
  }

  updateCartItems() {
    var data = locator.get<OfflineStorage>().getItem('cart');
    if (data['data'] != null) {
      var customerName = locator.get<StorageService>().customerSelected;
      if (customerName != null) {
        var cart = Cartlist.fromJson(json.decode(data['data']));
        if (cart.cartList != null) {
          items = cart.cartList!;
        }
      }
      notifyListeners();
    }
  }
}
