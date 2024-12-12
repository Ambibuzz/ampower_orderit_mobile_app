class SalesOrderList {
  List<SalesOrder>? salesOrderList;

  SalesOrderList({this.salesOrderList});

  SalesOrderList.fromJson(Map<String, dynamic> json) {
    salesOrderList = List.from(json['sales_order_list'])
        .map((e) => SalesOrder.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (salesOrderList != null) {
      data['sales_order_list'] =
          salesOrderList?.map((v) => v.toSalesOrderJson()).toList();
    }
    return data;
  }
}

class SalesOrder {
  final String? name;
  final int? docstatus;
  final double? perbilled;
  final double? perdelivered;
  final String? customer;
  final String? company;
  final String? ordertype;
  final String? transactiondate;
  final String? deliverydate;
  final double? advancepaid;
  final double? grandtotal;
  final double? basegrandtotal;
  final String? portofdischarge;
  final double? totalnetweight;
  final double? totalqty;
  final String? status;
  final String? podate;
  final String? pono;
  final String? setwarehouse;
  final List<SalesOrderItems>? salesOrderItems;
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

  SalesOrder({
    this.docstatus,
    this.salesOrderItems,
    this.setwarehouse,
    this.podate,
    this.pono,
    this.perdelivered,
    this.perbilled,
    this.status,
    this.customer,
    this.company,
    this.ordertype,
    this.transactiondate,
    this.deliverydate,
    this.advancepaid,
    this.grandtotal,
    this.basegrandtotal,
    this.portofdischarge,
    this.totalnetweight,
    this.totalqty,
    this.name,
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
  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    var soi = <SalesOrderItems>[];
    if (json['items'] != null) {
      var list = json['items'] as List;
      for (var listJson in list) {
        soi.add(SalesOrderItems.fromJson(listJson));
      }
    }
    return SalesOrder(
      advancepaid: json['advance_paid'] ?? 0,
      basegrandtotal: json['base_grand_total'] ?? 0,
      company: json['company'] ?? '',
      customer: json['customer'] ?? '',
      deliverydate: json['delivery_date'] ?? '',
      grandtotal: json['grand_total'] ?? 0,
      ordertype: json['order_type'] ?? '',
      portofdischarge: json['port_of_discharge'] ?? '',
      totalnetweight: json['total_net_weight'] ?? 0,
      totalqty: json['total_qty'] ?? 0,
      transactiondate: json['transaction_date'] ?? '',
      status: json['status'] ?? 'Draft',
      name: json['name'] ?? '',
      perbilled: json['per_billed'] ?? 0,
      podate: json['podate'] ?? '',
      pono: json['pono'] ?? '',
      perdelivered: json['per_delivered'] ?? 0,
      setwarehouse: json['set_warehouse'] ?? '',
      salesOrderItems: soi,
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

  //For converting model to json format for storing it in quality inspection model
  Map<String, dynamic> toJson() {
    var salesOrderItemsList = salesOrderItems != null
        ? salesOrderItems!.map((i) => i.salesOrderToJson()).toList()
        : null;
    return {
      'docstatus': docstatus,
      'company': company,
      'customer': customer,
      'set_warehouse': setwarehouse,
      'delivery_date': deliverydate,
      'items': salesOrderItemsList,
    };
  }

  Map<String, dynamic> toSalesOrderJson() {
    var data = <String, dynamic>{};
    var salesOrderItemsList = salesOrderItems != null
        ? salesOrderItems!.map((i) => i.salesOrderToJson()).toList()
        : null;
    data['advance_paid'] = advancepaid;
    data['base_grand_total'] = basegrandtotal;
    data['company'] = company;
    data['customer'] = customer;
    data['delivery_date'] = deliverydate;
    data['grand_total'] = grandtotal;
    data['order_type'] = ordertype;
    data['port_of_discharge'] = portofdischarge;
    data['total_net_weight'] = totalnetweight;
    data['total_qty'] = totalqty;
    data['transaction_date'] = transactiondate;
    data['status'] = status;
    data['name'] = name;
    data['per_billed'] = perbilled;
    data['podate'] = podate;
    data['pono'] = pono;
    data['per_delivered'] = perdelivered;
    data['set_warehouse'] = setwarehouse;
    if (salesOrderItems != null) {
      data['items'] = salesOrderItemsList;
    }
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

class SalesOrderItems {
  double? qty;
  String? deliverydate;
  String? itemcode;
  String? itemname;
  double? amount;
  double? rate;

  SalesOrderItems({
    this.qty,
    this.deliverydate,
    this.itemcode,
    this.itemname,
    this.amount,
    this.rate,
  });

  factory SalesOrderItems.fromJson(Map<String, dynamic> json) {
    return SalesOrderItems(
      amount: json['amount'] ?? 0,
      deliverydate: json['delivery_date'] ?? '',
      itemcode: json['item_code'] ?? '',
      itemname: json['item_name'] ?? '',
      qty: json['qty'] ?? 0,
      rate: json['rate'] ?? 0,
    );
  }

  // For converting model to json format for storing it in quality inspection readings
  Map<String,dynamic> toJson() => {
        'delivery_date': deliverydate,
        'item_code': itemcode,
        'qty': qty,
      };

  Map<String,dynamic> salesOrderToJson() => {
        'delivery_date': deliverydate,
        'item_code': itemcode,
        'item_name': itemname,
        'amount': amount,
        'rate': rate,
        'qty': qty,
      };
}

class SalesOrderPaymentSchedule {
  final String? paymentterm;
  final double? paymentamount;
  final String? duedate;
  final double? invoiceportion;
  final String? description;

  SalesOrderPaymentSchedule(
      {this.paymentterm,
      this.paymentamount,
      this.duedate,
      this.invoiceportion,
      this.description});
  factory SalesOrderPaymentSchedule.fromJson(Map<String, dynamic> json) {
    return SalesOrderPaymentSchedule(
      description: json['description'] ?? '',
      duedate: json['due_date'] ?? '',
      invoiceportion: json['invoice_portion'] ?? 0,
      paymentamount: json['payment_amount'] ?? 0,
      paymentterm: json['payment_term'] ?? '',
    );
  }
}
