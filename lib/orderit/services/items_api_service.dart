import 'dart:convert';

import 'package:orderit/common/models/item_price_model.dart';
import 'package:orderit/common/services/doctype_caching_service.dart';
import 'package:orderit/common/services/fetch_cached_doctype_service.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/file_model.dart';
import 'package:orderit/orderit/models/item_group.dart';
import 'package:orderit/orderit/models/items_model.dart';
import 'package:orderit/common/models/product.dart';
import 'package:orderit/common/services/offline_storage_service.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';
import 'package:orderit/util/constants/strings.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:orderit/util/enums.dart';

class ItemsService {
  Future<List<ItemsModel>> getItemsList(
      ConnectivityStatus connectivityStatus) async {
    var itemsList = <ItemsModel>[];
    try {
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        var data = locator.get<OfflineStorage>().getItem(Strings.item);
        // contains cached item cached data
        if (data['data'] != null) {
          return await locator
              .get<FetchCachedDoctypeService>()
              .fetchCachedItemItemsModelData();
        }
        // if cached data is not present load data from api
        else {
          return await getItems();
        }
      } else {
        // offline
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedItemItemsModelData();
      }
    } catch (e) {
      exception(e, '/api/resource/Item', 'getItemsList');
    }
    return itemsList;
  }

  Future<List<ItemsModel>> getItems() async {
    var itemsList = <ItemsModel>[];

    final response = await DioHelper.dio?.get('/api/resource/Item',
        queryParameters: {
          'fields': '["item_code","item_name","image"]',
          'limit_page_length': '*'
        });

    if (response?.statusCode == 200) {
      var data = response?.data;
      List listData = data['data'];
      for (var itemData in listData) {
        itemsList.add(ItemsModel.fromJson(itemData));
      }
      return itemsList;
    } else {
      await showErrorToast(response);
    }
    return itemsList;
  }

  Future<List<ItemsModel>> getItemsListFromItemName(
      String text, ConnectivityStatus connectivityStatus) async {
    var itemsList = <ItemsModel>[];
    try {
      final response = await DioHelper.dio?.get(
        '/api/resource/Item',
        queryParameters: {
          'fields': '["*"]',
          'filters': '[["Item","item_name","like","%$text%"]]',
          'limit_page_length': '*'
        },
      );

      if (response?.statusCode == 200) {
        List listData = response?.data['data'];
        for (var i in listData) {
          var model = ItemsModel.fromJson(i);
          var images = await locator
              .get<ItemsViewModel>()
              .getImages(model.itemCode, connectivityStatus);
          var finalModel = ItemsModel(
            imageUrl: model.imageUrl,
            itemCode: model.itemCode,
            itemDescription: model.itemDescription,
            itemName: model.itemName,
            price: 0,
            quantity: model.quantity,
            hasVariants: model.hasVariants,
            variantOf: model.variantOf,
            attributes: model.attributes,
            itemTags: model.itemTags,
            images: images ?? [],
            itemGroup: model.itemGroup,
          );
          itemsList.add(finalModel);
        }
        return itemsList;
      }
    } catch (e) {
      exception(e, '/api/resource/Item', 'getItemsListFromItemName');
    }
    return [];
  }

  Future<List<ItemsModel>> getItemsListFromItemCode(
      String text, ConnectivityStatus connectivityStatus) async {
    var itemsList = <ItemsModel>[];
    try {
      final response = await DioHelper.dio?.get(
        '/api/resource/Item',
        queryParameters: {
          'fields': '["*"]',
          'filters': '[["Item","item_code","like","%$text%"]]',
          'limit_page_length': '*'
        },
      );
      if (response?.statusCode == 200) {
        List listData = response?.data['data'];
        for (var i in listData) {
          var model = ItemsModel.fromJson(i);
          var images = await locator
              .get<ItemsViewModel>()
              .getImages(model.itemCode, connectivityStatus);
          var finalModel = ItemsModel(
            imageUrl: model.imageUrl,
            itemCode: model.itemCode,
            itemDescription: model.itemDescription,
            itemName: model.itemName,
            price: 0,
            quantity: model.quantity,
            hasVariants: model.hasVariants,
            variantOf: model.variantOf,
            attributes: model.attributes,
            itemTags: model.itemTags,
            images: images ?? [],
            itemGroup: model.itemGroup,
          );
          itemsList.add(finalModel);
        }
        return itemsList;
      }
    } catch (e) {
      exception(e, '/api/resource/Item', 'getItemsListFromItemCode');
    }
    return [];
  }

  Future<List<ItemsModel>> getSpecificItemDataFromItemName(
      String text, ConnectivityStatus connectivityStatus) async {
    var itemsList = <ItemsModel>[];
    try {
      final response = await DioHelper.dio?.get(
        '/api/resource/Item',
        queryParameters: {
          'fields': '["*"]',
          'filters': '[["Item","item_name","like","$text"]]',
          'limit_page_length': '*'
        },
      );
      if (response?.statusCode == 200) {
        List listData = response?.data['data'];
        for (var i in listData) {
          var model = ItemsModel.fromJson(i);
          var images = await locator
              .get<ItemsViewModel>()
              .getImages(model.itemCode, connectivityStatus);
          double price = await getPrice(model.itemCode!);
          var finalModel = ItemsModel(
            imageUrl: model.imageUrl,
            itemCode: model.itemCode,
            itemDescription: model.itemDescription,
            itemName: model.itemName,
            price: price,
            quantity: model.quantity,
            hasVariants: model.hasVariants,
            variantOf: model.variantOf,
            attributes: model.attributes,
            itemTags: model.itemTags,
            images: images ?? [],
            itemGroup: model.itemGroup,
          );
          itemsList.add(finalModel);
        }
      }

      return itemsList;
    } catch (e) {
      exception(e, '/api/resource/Item', 'getSpecificItemDataFromItemName');
    }
    return [];
  }

  Future<List<ItemsModel>> getSpecificItemDataFromItemCode(
      String text, ConnectivityStatus connectivityStatus) async {
    var itemsList = <ItemsModel>[];
    try {
      // final url = specificItemNameDataUrl(text);
      final response = await DioHelper.dio?.get(
        '/api/resource/Item',
        queryParameters: {
          'fields': '["*"]',
          'filters': '[["Item","item_code","like","$text"]]',
          'limit_page_length': '*'
        },
      );
      if (response?.statusCode == 200) {
        List listData = response?.data['data'];
        for (var i in listData) {
          var model = ItemsModel.fromJson(i);
          var images = await locator
              .get<ItemsViewModel>()
              .getImages(model.itemCode, connectivityStatus);
          double price = await getPrice(model.itemCode!);
          var finalModel = ItemsModel(
            imageUrl: model.imageUrl,
            itemCode: model.itemCode,
            itemDescription: model.itemDescription,
            itemName: model.itemName,
            price: price,
            quantity: model.quantity,
            hasVariants: model.hasVariants,
            variantOf: model.variantOf,
            attributes: model.attributes,
            itemTags: model.itemTags,
            images: images ?? [],
            itemGroup: model.itemGroup,
          );
          itemsList.add(finalModel);
        }
        return itemsList;
      }
    } catch (e) {
      exception(e, '/api/resource/Item', 'getSpecificItemDataFromItemCode');
    }
    return [];
  }

  Future<List<ItemsModel>> getItemFromItemGroup(
      String itemGroupName, ConnectivityStatus connectivityStatus) async {
    var itemsList = <ItemsModel>[];
    try {
      // online
      if (connectivityStatus == ConnectivityStatus.cellular ||
          connectivityStatus == ConnectivityStatus.wifi) {
        var data = locator.get<OfflineStorage>().getItem(Strings.item);
        // contains cached item cached data
        if (data['data'] != null) {
          return await locator
              .get<FetchCachedDoctypeService>()
              .fetchCachedItemDataFromItemGroup(
                  itemGroupName, connectivityStatus);
        }
        // if cached data is not present load data from api
        else {
          return await getItemFromItemGroupApi(itemGroupName);
        }
      } else {
        // offline
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedItemDataFromItemGroup(
                itemGroupName, connectivityStatus);
      }
    } catch (e) {
      exception(e, '/api/resource/Item', 'getItemGroupData');
    }
    return itemsList;
  }

  Future<List<ItemsModel>> getItemFromTag(String tag) async {
    var itemsList = <ItemsModel>[];
    final response =
        await DioHelper.dio?.get('/api/resource/Item', queryParameters: {
      'fields': '["item_code","item_name","image","has_variants","variant_of"]',
      'filters': '[["Item","_user_tags","like","%$tag%"]]',
      'limit_page_length': '*'
    });
    // await prices(itemgroup);
    if (response?.statusCode == 200) {
      List listData = response?.data['data'];
      for (var i in listData) {
        var model = ItemsModel.fromJson(i);
        var finalModel = ItemsModel(
            imageUrl: model.imageUrl,
            itemCode: model.itemCode,
            itemDescription: model.itemDescription,
            itemName: model.itemName,
            price: 0,
            quantity: model.quantity,
            hasVariants: model.hasVariants,
            variantOf: model.variantOf,
            attributes: model.attributes,
            itemTags: model.itemTags);
        itemsList.add(finalModel);
      }
      return itemsList;
    } else {
      await showErrorToast(response);
    }
    return itemsList;
  }

  Future<List<ItemsModel>> getItemFromItemGroupApi(String itemGroupName) async {
    var itemsList = <ItemsModel>[];
    final response =
        await DioHelper.dio?.get('/api/resource/Item', queryParameters: {
      'fields': '["item_code","item_name","image","has_variants","variant_of"]',
      'filters': '[["Item","item_group","=","$itemGroupName"]]',
      'limit_page_length': '*'
    });
    if (response?.statusCode == 200) {
      List listData = response?.data['data'];
      for (var i in listData) {
        var model = ItemsModel.fromJson(i);
        var finalModel = ItemsModel(
            imageUrl: model.imageUrl,
            itemCode: model.itemCode,
            itemDescription: model.itemDescription,
            itemName: model.itemName,
            price: 0,
            quantity: model.quantity,
            hasVariants: model.hasVariants,
            variantOf: model.variantOf,
            attributes: model.attributes,
            itemTags: model.itemTags);
        itemsList.add(finalModel);
      }
      return itemsList;
    } else {
      await showErrorToast(response);
    }
    return itemsList;
  }

  Future<List<ItemGroupModel>> getItemGroupList(
      ConnectivityStatus connectivityStatus) async {
    // online
    if (connectivityStatus == ConnectivityStatus.cellular ||
        connectivityStatus == ConnectivityStatus.wifi) {
      var data = locator.get<OfflineStorage>().getItem(Strings.itemGroupList);
      // contains cached item cached data
      if (data['data'] != null) {
        return await locator
            .get<FetchCachedDoctypeService>()
            .fetchCachedItemGroupListData();
      }
      // if cached data is not present load data from api
      else {
        // cache itemGroup
        await locator
            .get<DoctypeCachingService>()
            .cacheDoctype(Strings.itemGroupTree, 7, connectivityStatus);
        return await itemGroupList();
      }
    } else {
      // offline
      return await locator
          .get<FetchCachedDoctypeService>()
          .fetchCachedItemGroupListData();
    }
  }

  Future<List<ItemGroupModel>> itemGroupList() async {
    var itemGroupList = <ItemGroupModel>[];
    try {
      final response = await DioHelper.dio?.get(
        '/api/resource/Item%20Group',
        queryParameters: {
          'fields': '["image","item_group_name"]',
          'limit_page_length': '*',
          'order_by': 'item_group_name asc',
        },
      );
      var data = response?.data;
      List listData = data['data'];
      for (var itemGroup in listData) {
        itemGroupList.add(ItemGroupModel.fromJson(itemGroup));
      }
      return itemGroupList;
    } catch (e) {
      exception(e, '/api/resource/Item%20Group', 'itemGroupList');
    }
    return itemGroupList;
  }

  Future<dynamic> itemGroupTreeList() async {
    try {
      var body = {
        'doctype': 'Item Group',
        'label': 'All Item Groups',
        'parent': 'All Item Groups',
        'is_root': true,
        'tree_method': 'frappe.desk.treeview.get_children'
      };
      final response = await DioHelper.dio
          ?.post('/api/method/frappe.desk.treeview.get_all_nodes', data: body);

      var data = response?.data;
      var list = data['message'] as List;
      return list;
    } catch (e) {
      exception(e, '/api/method/frappe.desk.treeview.get_all_nodes',
          'itemGroupTreeList');
    }
    return '';
  }

  Future<List<ItemsModel>> getItemBrandData(String brandName) async {
    var itemsList = <ItemsModel>[];
    itemsList.clear();

    // final itemBrand = brandDataUrl(brandName);
    try {
      final response = await DioHelper.dio?.get(
        '/api/resource/Item',
        queryParameters: {
          'fields': '["item_code","item_name","image"]',
          'filters': '[["Item","brand","=","$brandName"]]',
          'limit_page_length': '*'
        },
      );

      if (response?.statusCode == 200) {
        var data = response?.data;
        List list = data['data'];
        for (var item in list) {
          String itemName = item['item_name'];
          String itemCode = item['item_code'];
          itemsList.add(ItemsModel(itemName: itemName, itemCode: itemCode));
        }
        return itemsList;
      }
    } catch (e) {
      exception(e, '/api/resource/Item', 'getItemBrandData');
    }
    return itemsList;
  }

  Future<List<ItemsModel>> getItem(String item) async {
    var itemsList = <ItemsModel>[];
    itemsList.clear();
    try {
      final itemNameResponse = await DioHelper.dio?.get(
        '/api/resource/Item',
        queryParameters: {
          'fields': '["*"]',
          'filters': '[["Item","item_name","like","$item"]]',
          'limit_page_length': '*'
        },
      );
      if (itemNameResponse?.statusCode == 200) {
        var list = itemNameResponse?.data['data'] as List;
        for (var listJson in list) {
          String itemName = listJson['item_name'];
          String itemCode = listJson['item_code'];
          itemsList.add(ItemsModel(itemName: itemName, itemCode: itemCode));
        }
        return itemsList;
      } else {
        await showErrorToast(itemNameResponse);
      }

      // }
    } catch (e) {
      exception(e, '/api/resource/Item', 'getItem');
    }
    return itemsList;
  }

  // get item price
  Future getPrice(String itemCode) async {
    var price = 0.0;
    try {
      var data = locator.get<OfflineStorage>().getItem(Strings.itemPrice);
      if (data['data'] != null) {
        var itemdata = jsonDecode(data['data']);
        var itemPriceList = ItemPriceList.fromJson(itemdata);

        if (itemPriceList.itemPriceList != null) {
          var customerItemPrices = itemPriceList.itemPriceList!;
          var customerPriceList = locator.get<StorageService>().priceList;
          var item = customerItemPrices.firstWhere(
              (e) =>
                  (e.itemCode == itemCode) &&
                  (e.priceList == customerPriceList),
              orElse: () => ItemPrice());
          if (item.priceListRate != null) {
            price = item.priceListRate!;
            return price;
          }
          return 0.0;
        }
        return price;
      } else {
        return 0.0;
      }
    } catch (e) {
      exception(e, '', 'getPrice');
    }
    return price;
  }

  //For fetching data from item api in product model
  Future<Product> getData(String url, {String? dropDownText}) async {
    try {
      final response = await DioHelper.dio?.get(url);
      if (response?.statusCode == 200) {
        return Product.fromJson(response?.data['data']);
      }
    } catch (e) {
      exception(e, url, 'getData');
    }
    return Product();
  }

  //For fetching data from item api in product model
  Future<List<FileModelOrderIT>> getImages(String? itemname) async {
    var fileList = <FileModelOrderIT>[];
    var url = '/api/resource/File';
    var queryParams = {
      'fields': '["file_url"]',
      'filters':
          '[["File","attached_to_doctype","=","Item"],["File","attached_to_name","=","$itemname"],["File","is_private","=",0]]',
    };
    try {
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );
      if (response?.statusCode == 200) {
        var list = response?.data['data'] as List;
        for (var i = 0; i < list.length; i++) {
          String? fileurl = list[i]['file_url'];
          if (fileurl != null) {
            if (fileurl.endsWith('jpg') ||
                fileurl.endsWith('jpeg') ||
                fileurl.endsWith('png') ||
                fileurl.endsWith('webp') ||
                fileurl.endsWith('bmp') ||
                fileurl.endsWith('wbmp')) {
              fileList.add(FileModelOrderIT.fromJson(list[i]));
            }
          }
        }
        return fileList;
      }
    } catch (e) {
      exception(e, url, 'getImages');
    }
    return [];
  }

  Future<List<ItemsModel>> getTags() async {
    var itemsList = <ItemsModel>[];
    final response = await DioHelper.dio?.get('/api/resource/Item',
        queryParameters: {
          'fields': '["item_code","item_name","image"]',
          'limit_page_length': '*'
        });

    if (response?.statusCode == 200) {
      var data = response?.data;
      List listData = data['data'];
      for (var itemData in listData) {
        itemsList.add(ItemsModel.fromJson(itemData));
      }
      return itemsList;
    } else {
      await showErrorToast(response);
    }
    return itemsList;
  }

  //For fetching data from item api in product model
  Future<List<Product>> getVariantsFromItemCode(String? itemcode) async {
    var products = <Product>[];
    products.clear();
    try {
      var data = locator.get<OfflineStorage>().getItem(Strings.item);
      // cached data is there then show cached item
      if (data['data'] != null) {
        var itemdata = jsonDecode(data['data']);
        var productList = ProductList.fromJson(itemdata);
        if (productList.productList != null) {
          var list = productList.productList!;
          products = list.where((item) => item.variantOf == itemcode).toList();
          return products;
        }
        // product list is null
        else {
          return await getVariantsFromItemCodeApi(itemcode);
        }
      }
      // load from api
      else {}
    } catch (e) {
      exception(e, '/api/resource/Item', 'getVariantsFromItemCode');
    }
    return [];
  }

  Future<List<Product>> getVariantsFromItemCodeApi(String? itemcode) async {
    var products = <Product>[];

    final response = await DioHelper.dio?.get(
      '/api/resource/Item',
      queryParameters: {
        'fields': '["*"]',
        'filters': '[["Item","variant_of","=","$itemcode"]]',
        'limit_page_length': '*'
      },
    );
    if (response?.statusCode == 200) {
      var list = response?.data['data'] as List;
      for (var i in list) {
        products.add(Product.fromJson(i));
      }
      return products;
    } else {
      await showErrorToast(response);
    }
    return products;
  }

  Future<List<ItemsModel>> mapProductToItemModel(List<Product> products) async {
    var items = <ItemsModel>[];
    items.clear();
    for (var i = 0; i < products.length; i++) {
      var price =
          await locator.get<ItemsService>().getPrice(products[i].itemCode!);
      var item = ItemsModel(
        // attributes: products[i].attributes,
        hasVariants: products[i].hasVariants,
        imageUrl: products[i].image,
        itemCode: products[i].itemCode,
        itemDescription: products[i].description,
        itemName: products[i].itemName,
        price: price,
        quantity: 0,
        variantOf: products[i].variantOf,
        itemGroup: products[i].itemGroup,
      );
      items.add(item);
    }
    return items;
  }
}
