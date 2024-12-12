class QuotationModel {
  final String? currency;
  final List<QuotationItems>? quotationitems;
  final String? customer;
  final String? company;
  final String? transactiondate;
  final String? priceList;
  final String? priceListCurrency;

  QuotationModel({
    this.currency,
    this.quotationitems,
    this.customer,
    this.priceList,
    this.priceListCurrency,
    this.company,
    this.transactiondate,
  });

  Map toJson() {
    var quoItems = quotationitems != null
        ? quotationitems?.map((i) => i.toJson()).toList()
        : null;
    return {
      'currency': currency,
      'items': quoItems,
      'customer_name': customer,
      'transaction_date': transactiondate,
      'company': company,
      'party_name': customer,
      'order_type': 'Sales',
      'price_list_currency': priceListCurrency,
      'selling_price_list': priceList,
    };
  }
}

class QuotationItems {
  final String? itemcode;
  final int? quantity;
  final double? rate;

  QuotationItems({this.itemcode, this.quantity, this.rate});

  Map toJson() {
    return {'item_code': itemcode, 'qty': quantity, 'rate': rate};
  }
}
