class PriceList {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? idx;
  int? docstatus;
  int? enabled;
  String? priceListName;
  String? currency;
  int? buying;
  int? selling;
  int? priceNotUomDependent;
  String? doctype;

  PriceList({
    this.name,
    this.owner,
    this.creation,
    this.modified,
    this.modifiedBy,
    this.idx,
    this.docstatus,
    this.enabled,
    this.priceListName,
    this.currency,
    this.buying,
    this.selling,
    this.priceNotUomDependent,
    this.doctype,
  });

  PriceList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    enabled = json['enabled'];
    priceListName = json['price_list_name'];
    currency = json['currency'];
    buying = json['buying'];
    selling = json['selling'];
    priceNotUomDependent = json['price_not_uom_dependent'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['idx'] = idx;
    data['docstatus'] = docstatus;
    data['enabled'] = enabled;
    data['price_list_name'] = priceListName;
    data['currency'] = currency;
    data['buying'] = buying;
    data['selling'] = selling;
    data['price_not_uom_dependent'] = priceNotUomDependent;
    data['doctype'] = doctype;
    return data;
  }
}
