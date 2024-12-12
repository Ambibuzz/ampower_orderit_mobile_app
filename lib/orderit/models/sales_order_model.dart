class SalesOrderModel {
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
  final String? priceList;
  final String? priceListCurrency;
  final String? currency;

  final List<SalesOrderItemsModel>? salesOrderItems;

  SalesOrderModel({
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
    this.currency,
    this.priceList,
    this.priceListCurrency,
  });
  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    var soi = <SalesOrderItemsModel>[];
    if (json['items'] != null) {
      var list = json['items'] as List;
      for (var listJson in list) {
        soi.add(SalesOrderItemsModel.fromJson(listJson));
      }
    }
    return SalesOrderModel(
      advancepaid: json['advance_paid'],
      basegrandtotal: json['base_grand_total'],
      company: json['company'],
      customer: json['customer'],
      deliverydate: json['delivery_date'],
      grandtotal: json['grand_total'],
      ordertype: json['order_type'],
      portofdischarge: json['port_of_discharge'],
      totalnetweight: json['total_net_weight'],
      totalqty: json['total_qty'],
      transactiondate: json['transaction_date'],
      status: json['status'],
      name: json['name'],
      perbilled: json['per_billed'],
      podate: json['podate'],
      pono: json['pono'],
      perdelivered: json['per_delivered'],
      setwarehouse: json['set_warehouse'],
      salesOrderItems: soi,
    );
  }

  //For converting model to json format for storing it in quality inspection model
  Map<String, dynamic> toJson() {
    var salesOrderItemsList = salesOrderItems != null
        ? salesOrderItems!.map((i) => i.toJson()).toList()
        : null;
    return {
      'docstatus': docstatus,
      'company': company,
      'customer': customer,
      'set_warehouse': setwarehouse,
      'transaction_date': transactiondate,
      'order_type': ordertype,
      // 'currency': currency,
      'selling_price_list': priceList,
      // 'price_list_currency': priceListCurrency,
      'items': salesOrderItemsList
    };
  }
}

class SalesOrderItemsModel {
  double? qty;
  String? deliverydate;
  String? itemcode;
  String? itemname;
  double? amount;
  double? rate;

  SalesOrderItemsModel({
    this.qty,
    this.deliverydate,
    this.itemcode,
    this.itemname,
    this.amount,
    this.rate,
  });

  factory SalesOrderItemsModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderItemsModel(
      amount: json['amount'] ?? 0,
      deliverydate: json['delivery_date'] ?? '',
      itemcode: json['item_code'] ?? '',
      itemname: json['item_name'] ?? '',
      qty: json['qty'] ?? 0,
      rate: json['rate'] ?? 0,
    );
  }

  //For converting model to json format for storing it in quality inspection readings
  Map<String, dynamic> toJson() => {
        'item_code': itemcode,
        'qty': qty,
        'rate': rate,
        'delivery_date': deliverydate
      };
}
