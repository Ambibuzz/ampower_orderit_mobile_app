class QuotationList {
  List<Quotation>? quotationList;

  QuotationList({this.quotationList});

  QuotationList.fromJson(Map<String, dynamic> json) {
    quotationList = List.from(json['quotation_list'])
        .map((e) => Quotation.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (quotationList != null) {
      data['quotation_list'] =
          quotationList?.map((v) => v.toQuotationJson()).toList();
    }
    return data;
  }
}

class Quotation {
  final String quotationTo;
  final String partyName;
  final String customerName;
  final String company;
  final String date;
  final String validTill;
  final String orderType;
  final String currency;
  final String priceList;
  final double totalQuantity;
  final double totalINR;
  final double totalNetWeight;
  final double grandTotal;
  final double roundedTotal;
  final String inWords;
  final String doctype;
  final String status;
  final String name;
  final String contactEmail;
  final String contactNumber;
  List<QuotationItem>? qi;
  final String? customerAddress;
  final String? shippingAddressName;
  final String? shippingAddress;
  final String? addressDisplay;
  final String? contactPerson;
  final String? contactDisplay;
  final String? contactPhone;
  final String? contactMobile;
  final String? companyAddress;
  final String? territory;
  final String? dispatchAddressName;

  Quotation({
    this.quotationTo = '',
    this.partyName = '',
    this.customerName = '',
    this.company = '',
    this.date = '',
    this.validTill = '',
    this.orderType = '',
    this.currency = '',
    this.priceList = '',
    this.totalQuantity = 0,
    this.totalINR = 0,
    this.totalNetWeight = 0,
    this.grandTotal = 0,
    this.roundedTotal = 0,
    this.inWords = '',
    this.doctype = '',
    this.status = '',
    this.name = '',
    this.contactEmail = '',
    this.contactNumber = '',
    this.qi,
    this.customerAddress,
    this.shippingAddressName,
    this.shippingAddress,
    this.addressDisplay,
    this.contactPerson,
    this.contactDisplay,
    this.contactPhone,
    this.contactMobile,
    this.companyAddress,
    this.territory,
    this.dispatchAddressName,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    var qi = <QuotationItem>[];
    if (json['items'] != null) {
      var list = json['items'] as List;
      for (var listJson in list) {
        qi.add(QuotationItem.fromJson(listJson));
      }
    }
    return Quotation(
      qi: qi,
      company: json['company'] ?? '',
      currency: json['currency'] ?? '',
      customerName: json['customer_name'] ?? '',
      date: json['transaction_date'] ?? '',
      doctype: json['doctype'] ?? '',
      grandTotal: json['grand_total'] ?? 0,
      inWords: json['in_words'] ?? '',
      orderType: json['order_type'] ?? '',
      partyName: json['party_name'] ?? '',
      priceList: json['selling_price_list'] ?? '',
      quotationTo: json['quotation_to'] ?? '',
      roundedTotal: json['rounded_total'] ?? 0,
      totalINR: json['total'] ?? 0,
      totalNetWeight: json['total_net_weight'] ?? 0,
      totalQuantity: json['total_qty'] ?? 0,
      validTill: json['valid_till'] ?? '',
      status: json['status'] ?? '',
      name: json['name'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      contactNumber: json['contact_mobile'] ?? '',
      customerAddress: json['customer_address'],
      shippingAddressName: json['shipping_address_name'],
      shippingAddress: json['shipping_address'],
      addressDisplay: json['address_display'],
      contactPerson: json['contact_person'],
      contactDisplay: json['contact_display'],
      contactPhone: json['contact_phone'],
      contactMobile: json['contact_mobile'],
      companyAddress: json['company_address'],
      territory: json['territory'],
      dispatchAddressName: json['dispatch_address_name'],
    );
  }

  Map<String, dynamic> toQuotationJson() {
    var data = <String, dynamic>{};
    var quotationItemsList =
        qi != null ? qi!.map((i) => i.toJson()).toList() : [];
    if (qi != null) {
      data['items'] = quotationItemsList;
    }
    data['company'] = company;
    data['currency'] = currency;
    data['customer_name'] = customerName;
    data['transaction_date'] = date;
    data['doctype'] = doctype;
    data['grand_total'] = grandTotal;
    data['in_words'] = inWords;
    data['order_type'] = orderType;
    data['party_name'] = partyName;
    data['selling_price_list'] = priceList;
    data['quotation_to'] = quotationTo;
    data['rounded_total'] = roundedTotal;
    data['total'] = totalINR;
    data['total_net_weight'] = totalNetWeight;
    data['total_qty'] = totalQuantity;
    data['valid_till'] = validTill;
    data['status'] = status;
    data['name'] = name;
    data['contact_email'] = contactEmail;
    data['contact_mobile'] = contactNumber;
    data['customer_address'] = customerAddress;
    data['shipping_address_name'] = shippingAddressName;
    data['shipping_address'] = shippingAddress;
    data['address_display'] = addressDisplay;
    data['contact_person'] = contactPerson;
    data['contact_display'] = contactDisplay;
    data['contact_phone'] = contactPhone;
    data['contact_mobile'] = contactMobile;
    data['company_address'] = companyAddress;
    data['territory'] = territory;
    data['dispatch_address_name'] = dispatchAddressName;
    return data;
  }
}

class QuotationItem {
  final double? qty;
  final String? itemName;
  final String? itemCode;
  final String? itemGroup;
  final double? rate;
  final String? stockUom;
  final String? weightUom;
  final double? amount;
  final String description;

  QuotationItem({
    this.qty,
    this.itemName,
    this.itemCode,
    this.itemGroup,
    this.rate,
    this.stockUom,
    this.weightUom,
    this.amount,
    this.description = '',
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      amount: json['amount'] ?? 0,
      description: json['description'] ?? '',
      itemCode: json['item_code'] ?? '',
      itemGroup: json['item_group'] ?? '',
      itemName: json['item_name'] ?? '',
      qty: json['qty'] ?? 0,
      rate: json['rate'] ?? 0,
      stockUom: json['stock_uom'] ?? '',
      weightUom: json['weight_uom'] ?? '',
    );
  }

  Map toJson() => {
        'item_code': itemCode,
        'item_name': itemName,
        'amount': amount,
        'rate': rate,
        'qty': qty,
      };
}
