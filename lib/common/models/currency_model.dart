class CurrencyList {
  List<CurrencyModel>? currencyList;

  CurrencyList({this.currencyList});

  CurrencyList.fromJson(Map<String, dynamic> json) {
    currencyList = List.from(json['currency_list'])
        .map((e) => CurrencyModel.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (currencyList != null) {
      data['currency_list'] = currencyList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CurrencyModel {
  String? name;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? currencyName;
  int? enabled;
  String? fraction;
  int? fractionUnits;
  double? smallestCurrencyFractionValue;
  String? symbol;
  int? symbolOnRight;
  String? numberFormat;

  CurrencyModel({
    this.name,
    this.creation,
    this.modified,
    this.modifiedBy,
    this.docstatus,
    this.idx,
    this.currencyName,
    this.enabled,
    this.fraction,
    this.fractionUnits,
    this.smallestCurrencyFractionValue,
    this.symbol,
    this.symbolOnRight,
    this.numberFormat,
  });

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    currencyName = json['currency_name'];
    enabled = json['enabled'];
    fraction = json['fraction'];
    fractionUnits = json['fraction_units'];
    smallestCurrencyFractionValue = json['smallest_currency_fraction_value'];
    symbol = json['symbol'];
    symbolOnRight = json['symbol_on_right'];
    numberFormat = json['number_format'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['currency_name'] = currencyName;
    data['enabled'] = enabled;
    data['fraction'] = fraction;
    data['fraction_units'] = fractionUnits;
    data['smallest_currency_fraction_value'] = smallestCurrencyFractionValue;
    data['symbol'] = symbol;
    data['symbol_on_right'] = symbolOnRight;
    data['number_format'] = numberFormat;
    return data;
  }
}
