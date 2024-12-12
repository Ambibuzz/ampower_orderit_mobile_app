class GlobalDefaults {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  String? idx;
  int? docstatus;
  String? defaultCompany;
  String? currentFiscalYear;
  String? country;
  String? defaultDistanceUnit;
  String? defaultCurrency;
  String? hideCurrencySymbol;
  int? disableRoundedTotal;
  int? disableInWords;
  String? doctype;

  GlobalDefaults(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.idx,
      this.docstatus,
      this.defaultCompany,
      this.currentFiscalYear,
      this.country,
      this.defaultDistanceUnit,
      this.defaultCurrency,
      this.hideCurrencySymbol,
      this.disableRoundedTotal,
      this.disableInWords,
      this.doctype});

  GlobalDefaults.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    defaultCompany = json['default_company'];
    currentFiscalYear = json['current_fiscal_year'];
    country = json['country'];
    defaultDistanceUnit = json['default_distance_unit'];
    defaultCurrency = json['default_currency'];
    hideCurrencySymbol = json['hide_currency_symbol'];
    disableRoundedTotal = json['disable_rounded_total'];
    disableInWords = json['disable_in_words'];
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
    data['default_company'] = defaultCompany;
    data['current_fiscal_year'] = currentFiscalYear;
    data['country'] = country;
    data['default_distance_unit'] = defaultDistanceUnit;
    data['default_currency'] = defaultCurrency;
    data['hide_currency_symbol'] = hideCurrencySymbol;
    data['disable_rounded_total'] = disableRoundedTotal;
    data['disable_in_words'] = disableInWords;
    data['doctype'] = doctype;
    return data;
  }
}
