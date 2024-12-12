
class CustomerAndPriceListConfigurationModel {
  Map<String, dynamic>? customer;
  String? priceList;
  bool isUserCustomer;
  CustomerAndPriceListConfigurationModel({
    this.customer,
    this.priceList,
    this.isUserCustomer = false,
  });
  factory CustomerAndPriceListConfigurationModel.fromJson(
      Map<String, dynamic> json) {
    return CustomerAndPriceListConfigurationModel(
      customer: json['customer'],
      priceList: json['pricelist'],
      isUserCustomer: json['is_user_customer'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['customer'] = customer;
    data['pricelist'] = priceList;
    data['is_user_customer'] = isUserCustomer;
    return data;
  }
}
