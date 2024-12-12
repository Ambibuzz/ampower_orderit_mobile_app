import 'package:orderit/orderit/models/item_attribute.dart';

class ProductList {
  List<Product>? productList;
  ProductList({this.productList});

  ProductList.fromJson(Map<String, dynamic> json) {
    productList = List.from(json['product_list'])
        .map((e) => Product.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (productList != null) {
      data['product_list'] = productList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  String? brand;
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? idx;
  int? docstatus;
  String? namingSeries;
  String? image;
  String? itemCode;
  String? itemName;
  String? itemGroup;
  int? isNilExempt;
  int? isNonGst;
  int? isItemFromHub;
  String? stockUom;
  int? disabled;
  int? allowAlternativeItem;
  int? isStockItem;
  int? includeItemInManufacturing;
  double? openingStock;
  double? valuationRate;
  // int? standardRate;
  // int? isFixedAsset;
  // int? autoCreateAssets;
  // double? overDeliveryReceiptAllowance;
  // double? overBillingAllowance;
  String? description;
  int? shelfLifeInDays;
  String? endOfLife;
  String? defaultMaterialRequestType;
  String? valuationMethod;
  String? warrantyPeriod;
  double? weightPerUnit;
  int? hasBatchNo;
  int? createNewBatch;
  int? hasExpiryDate;
  int? retainSample;
  int? sampleQuantity;
  int? hasSerialNo;
  String? serialNoSeries;
  int? hasVariants;
  String? variantBasedOn;
  int? isPurchaseItem;
  double? minOrderQty;
  double? safetyStock;
  int? leadTimeDays;
  double? lastPurchaseRate;
  int? isCustomerProvidedItem;
  int? deliveredBySupplier;
  String? countryOfOrigin;
  int? isSalesItem;
  int? grantCommission;
  double? maxDiscount;
  int? enableDeferredRevenue;
  int? noOfMonths;
  int? enableDeferredExpense;
  int? noOfMonthsExp;
  int? inspectionRequiredBeforePurchase;
  int? inspectionRequiredBeforeDelivery;
  int? isSubContractedItem;
  String? customerCode;
  int? publishInHub;
  int? syncedWithHub;
  int? publishedInWebsite;
  double? totalProjectedQty;
  String? doctype;
  String? gstHsnCode;
  // List<ItemAttribute>? attributes;
  String? variantOf;

  Product({
    this.brand,
    this.name,
    this.owner,
    this.creation,
    this.modified,
    this.modifiedBy,
    this.idx,
    this.docstatus,
    this.namingSeries,
    this.image,
    this.itemCode,
    this.itemName,
    this.itemGroup,
    this.isNilExempt,
    this.isNonGst,
    this.isItemFromHub,
    this.stockUom,
    this.disabled,
    this.allowAlternativeItem,
    this.isStockItem,
    this.includeItemInManufacturing,
    this.openingStock,
    this.valuationRate,
    this.description,
    this.shelfLifeInDays,
    this.endOfLife,
    this.defaultMaterialRequestType,
    this.valuationMethod,
    this.warrantyPeriod,
    this.weightPerUnit,
    this.hasBatchNo,
    this.createNewBatch,
    this.hasExpiryDate,
    this.retainSample,
    this.sampleQuantity,
    this.hasSerialNo,
    this.serialNoSeries,
    this.hasVariants,
    this.variantBasedOn,
    this.isPurchaseItem,
    this.minOrderQty,
    this.safetyStock,
    this.leadTimeDays,
    this.lastPurchaseRate,
    this.isCustomerProvidedItem,
    this.deliveredBySupplier,
    this.countryOfOrigin,
    this.isSalesItem,
    this.grantCommission,
    this.maxDiscount,
    this.enableDeferredRevenue,
    this.noOfMonths,
    this.enableDeferredExpense,
    this.noOfMonthsExp,
    this.inspectionRequiredBeforePurchase,
    this.inspectionRequiredBeforeDelivery,
    this.isSubContractedItem,
    this.customerCode,
    this.publishInHub,
    this.syncedWithHub,
    this.publishedInWebsite,
    this.totalProjectedQty,
    this.doctype,
    this.gstHsnCode,
    // this.attributes,
    this.variantOf,
  });

  Product.fromJson(Map<String, dynamic> json) {
    // List<ItemAttribute>? attributeList = [];
    // if (json['attributes'] != null) {
    //   json['attributes'].forEach((v) {
    //     attributeList.add(ItemAttribute.fromJson(v));
    //   });
    // attributes = attributeList;
    // }

    brand = json['brand'];
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    namingSeries = json['naming_series'];
    image = json['image'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    itemGroup = json['item_group'];
    isNilExempt = json['is_nil_exempt'];
    isNonGst = json['is_non_gst'];
    isItemFromHub = json['is_item_from_hub'];
    stockUom = json['stock_uom'];
    disabled = json['disabled'];
    gstHsnCode = json['gst_hsn_code'];
    allowAlternativeItem = json['allow_alternative_item'];
    isStockItem = json['is_stock_item'];
    includeItemInManufacturing = json['include_item_in_manufacturing'];
    openingStock = json['opening_stock'];
    valuationRate = json['valuation_rate'];
    description = json['description'];
    shelfLifeInDays = json['shelf_life_in_days'];
    endOfLife = json['end_of_life'];
    defaultMaterialRequestType = json['default_material_request_type'];
    valuationMethod = json['valuation_method'];
    warrantyPeriod = json['warranty_period'];
    weightPerUnit = json['weight_per_unit'];
    hasBatchNo = json['has_batch_no'];
    createNewBatch = json['create_new_batch'];
    hasExpiryDate = json['has_expiry_date'];
    retainSample = json['retain_sample'];
    sampleQuantity = json['sample_quantity'];
    hasSerialNo = json['has_serial_no'];
    serialNoSeries = json['serial_no_series'];
    hasVariants = json['has_variants'];
    variantBasedOn = json['variant_based_on'];
    isPurchaseItem = json['is_purchase_item'];
    minOrderQty = json['min_order_qty'];
    safetyStock = json['safety_stock'];
    leadTimeDays = json['lead_time_days'];
    lastPurchaseRate = json['last_purchase_rate'];
    isCustomerProvidedItem = json['is_customer_provided_item'];
    deliveredBySupplier = json['delivered_by_supplier'];
    countryOfOrigin = json['country_of_origin'];
    isSalesItem = json['is_sales_item'];
    grantCommission = json['grant_commission'];
    maxDiscount = json['max_discount'];
    enableDeferredRevenue = json['enable_deferred_revenue'];
    noOfMonths = json['no_of_months'];
    enableDeferredExpense = json['enable_deferred_expense'];
    noOfMonthsExp = json['no_of_months_exp'];
    inspectionRequiredBeforePurchase =
        json['inspection_required_before_purchase'];
    inspectionRequiredBeforeDelivery =
        json['inspection_required_before_delivery'];
    isSubContractedItem = json['is_sub_contracted_item'];
    customerCode = json['customer_code'];
    publishInHub = json['publish_in_hub'];
    syncedWithHub = json['synced_with_hub'];
    publishedInWebsite = json['published_in_website'];
    totalProjectedQty = json['total_projected_qty'];
    doctype = json['doctype'];
    variantOf = json['variant_of'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    // if (attributes != null) {
    //   data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    // }
    data['name'] = name;
    data['item_code'] = itemCode;
    data['item_name'] = itemName;
    data['item_group'] = itemGroup;
    data['stock_uom'] = stockUom;
    data['description'] = description;
    data['shelf_life_in_days'] = shelfLifeInDays;
    data['warranty_period'] = warrantyPeriod;
    data['variant_of'] = variantOf;
    data['has_variants'] = hasVariants;
    data['image'] = image;
    return data;
  }
}

class ItemTags {
  String? tagName;

  ItemTags({this.tagName});

  ItemTags.fromJson(Map<String, dynamic> json) {
    tagName = json['tag_name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tag_name'] = tagName;
    return data;
  }
}
