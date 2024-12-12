class SalesInvoice {
  //imp fields
  int? docstatus;
  String? company;
  String? customerName;
  String? customer;
  String? lrDate;
  String? postingDate;
  String? postingTime;
  String? sellingPriceList;
  String? priceListCurrency;
  List<SalesInvoiceItems>? items;

  SalesInvoice({

    // imp fields
    this.docstatus,
    this.company,
    this.customerName,
    this.customer,
    this.lrDate,
    this.postingDate,
    this.postingTime,
    this.sellingPriceList,
    this.priceListCurrency,
    this.items,
  });

  SalesInvoice.fromJson(Map<String, dynamic> json) {

    //imp fields
    docstatus = json['docstatus'];
    company = json['company'];
    customerName = json['customer_name'];
    customer = json['customer'];
    lrDate = json['lr_date'];
    postingDate = json['posting_date'];
    postingTime = json['posting_time'];
    sellingPriceList = json['selling_price_list'];
    priceListCurrency = json['price_list_currency'];
    if (json['items'] != null) {
      items = <SalesInvoiceItems>[];
      json['items'].forEach((v) {
        items!.add(SalesInvoiceItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    //imp fields
    data['docstatus'] = docstatus;
    data['company'] = company;
    data['customer_name'] = customerName;
    data['customer'] = customer;
    data['lr_date'] = lrDate;
    data['posting_date'] = postingDate;
    data['posting_time'] = postingTime;
    data['selling_price_list'] = sellingPriceList;
    data['price_list_currency'] = priceListCurrency;

    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class SalesInvoiceItems {

  //imp
  double? qty;
  double? rate;
  double? amount;
  String? itemCode;
  String? itemName;

  SalesInvoiceItems({

    //imp
    this.qty,
    this.rate,
    this.amount,
    this.itemCode,
    this.itemName,
  });

  SalesInvoiceItems.fromJson(Map<String, dynamic> json) {

    //imp
    qty = json['qty'];
    rate = json['rate'];
    amount = json['amount'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    //imp
    data['qty'] = qty;
    data['rate'] = rate;
    data['amount'] = amount;
    data['item_code'] = itemCode;
    data['item_name'] = itemName;
    return data;
  }
}

class Taxes {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  String? parent;
  String? parentfield;
  String? parenttype;
  int? idx;
  int? docstatus;
  String? chargeType;
  String? accountHead;
  String? description;
  int? includedInPrintRate;
  int? includedInPaidAmount;
  int? rate;
  int? taxAmount;
  int? total;
  int? taxAmountAfterDiscountAmount;
  int? baseTaxAmount;
  int? baseTotal;
  int? baseTaxAmountAfterDiscountAmount;
  String? itemWiseTaxDetail;
  int? dontRecomputeTax;
  String? doctype;

  Taxes(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.docstatus,
      this.chargeType,
      this.accountHead,
      this.description,
      this.includedInPrintRate,
      this.includedInPaidAmount,
      this.rate,
      this.taxAmount,
      this.total,
      this.taxAmountAfterDiscountAmount,
      this.baseTaxAmount,
      this.baseTotal,
      this.baseTaxAmountAfterDiscountAmount,
      this.itemWiseTaxDetail,
      this.dontRecomputeTax,
      this.doctype});

  Taxes.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    chargeType = json['charge_type'];
    accountHead = json['account_head'];
    description = json['description'];
    includedInPrintRate = json['included_in_print_rate'];
    includedInPaidAmount = json['included_in_paid_amount'];
    rate = json['rate'];
    taxAmount = json['tax_amount'];
    total = json['total'];
    taxAmountAfterDiscountAmount = json['tax_amount_after_discount_amount'];
    baseTaxAmount = json['base_tax_amount'];
    baseTotal = json['base_total'];
    baseTaxAmountAfterDiscountAmount =
        json['base_tax_amount_after_discount_amount'];
    itemWiseTaxDetail = json['item_wise_tax_detail'];
    dontRecomputeTax = json['dont_recompute_tax'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['idx'] = idx;
    data['docstatus'] = docstatus;
    data['charge_type'] = chargeType;
    data['account_head'] = accountHead;
    data['description'] = description;
    data['included_in_print_rate'] = includedInPrintRate;
    data['included_in_paid_amount'] = includedInPaidAmount;
    data['rate'] = rate;
    data['tax_amount'] = taxAmount;
    data['total'] = total;
    data['tax_amount_after_discount_amount'] =
        taxAmountAfterDiscountAmount;
    data['base_tax_amount'] = baseTaxAmount;
    data['base_total'] = baseTotal;
    data['base_tax_amount_after_discount_amount'] =
        baseTaxAmountAfterDiscountAmount;
    data['item_wise_tax_detail'] = itemWiseTaxDetail;
    data['dont_recompute_tax'] = dontRecomputeTax;
    data['doctype'] = doctype;
    return data;
  }
}

class PaymentSchedule {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  String? parent;
  String? parentfield;
  String? parenttype;
  int? idx;
  int? docstatus;
  String? dueDate;
  int? invoicePortion;
  int? discount;
  int? paymentAmount;
  int? outstanding;
  int? paidAmount;
  int? discountedAmount;
  int? basePaymentAmount;
  String? doctype;

  PaymentSchedule(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.idx,
      this.docstatus,
      this.dueDate,
      this.invoicePortion,
      this.discount,
      this.paymentAmount,
      this.outstanding,
      this.paidAmount,
      this.discountedAmount,
      this.basePaymentAmount,
      this.doctype});

  PaymentSchedule.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    dueDate = json['due_date'];
    invoicePortion = json['invoice_portion'];
    discount = json['discount'];
    paymentAmount = json['payment_amount'];
    outstanding = json['outstanding'];
    paidAmount = json['paid_amount'];
    discountedAmount = json['discounted_amount'];
    basePaymentAmount = json['base_payment_amount'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['idx'] = idx;
    data['docstatus'] = docstatus;
    data['due_date'] = dueDate;
    data['invoice_portion'] = invoicePortion;
    data['discount'] = discount;
    data['payment_amount'] = paymentAmount;
    data['outstanding'] = outstanding;
    data['paid_amount'] = paidAmount;
    data['discounted_amount'] = discountedAmount;
    data['base_payment_amount'] = basePaymentAmount;
    data['doctype'] = doctype;
    return data;
  }
}
