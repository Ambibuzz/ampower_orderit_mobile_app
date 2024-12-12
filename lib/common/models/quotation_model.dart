class QuotationModel {
  final String? currency;
  final List<QuotationItems>? quotationitems;
  final String customerName;
  final String? quotationTo;
  final String partyName;
  final String contactDisplay;
  final String contactEmail;
  final String contactPerson;
  final String contactMobile;
  final String customerAddress;
  final String territory;

  QuotationModel({
    this.currency,
    this.quotationitems,
    this.customerName='',
    this.quotationTo,
    this.partyName='',
    this.contactDisplay='',
    this.contactEmail='',
    this.contactMobile='',
    this.contactPerson='',
    this.customerAddress='',
    this.territory='',
  });

  Map toJson() {
    var qoitems = quotationitems == null
        ? null
        : quotationitems!.map((i) => i.toJson()).toList();
    return {
      'currency': currency,
      'items': qoitems,
      'customer_name': customerName,
      'party_name': partyName,
      'quotation_to': quotationTo,
      'contact_display': contactDisplay,
      'contact_email': contactEmail,
      'contact_mobile': contactMobile,
      'contact_person': contactPerson,
      'customer_address': customerAddress,
      'territory': territory
    };
  }
}

class QuotationItems {
  final String itemcode;
  final int quantity;
  final double rate;

  QuotationItems(
      {required this.itemcode, required this.quantity, required this.rate});

  Map toJson() {
    return {'item_code': itemcode, 'qty': quantity, 'rate': rate};
  }
}
