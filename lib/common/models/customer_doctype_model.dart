class CustomerDoctype {
  List<Docs>? docs;

  CustomerDoctype({this.docs});

  CustomerDoctype.fromJson(Map<String, dynamic> json) {
    if (json['docs'] != null) {
      docs = <Docs>[];
      json['docs'].forEach((v) {
        docs!.add(Docs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (docs != null) {
      data['docs'] = docs!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Docs {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? namingSeries;
  String? customerName;
  String? customerType;
  String? customerGroup;
  String? territory;
  String? defaultCurrency;
  int? isInternalCustomer;
  String? language;
  String? gstCategory;
  String? doctype;
  List<CreditLimits>? creditLimits;
  Onload? oOnload;

  Docs(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.docstatus,
      this.idx,
      this.namingSeries,
      this.customerName,
      this.customerType,
      this.customerGroup,
      this.territory,
      this.defaultCurrency,
      this.isInternalCustomer,
      this.language,
      this.gstCategory,
      this.doctype,
      this.creditLimits,
      this.oOnload});

  Docs.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    namingSeries = json['naming_series'];
    customerName = json['customer_name'];
    customerType = json['customer_type'];
    customerGroup = json['customer_group'];
    territory = json['territory'];
    defaultCurrency = json['default_currency'];
    isInternalCustomer = json['is_internal_customer'];
    language = json['language'];
    gstCategory = json['gst_category'];
    doctype = json['doctype'];
    if (json['credit_limits'] != null) {
      creditLimits = <CreditLimits>[];
      json['credit_limits'].forEach((v) {
        creditLimits!.add(CreditLimits.fromJson(v));
      });
    }
    oOnload =
        json['__onload'] != null ? Onload.fromJson(json['__onload']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['naming_series'] = namingSeries;
    data['customer_name'] = customerName;
    data['customer_type'] = customerType;
    data['customer_group'] = customerGroup;
    data['territory'] = territory;
    data['default_currency'] = defaultCurrency;
    data['is_internal_customer'] = isInternalCustomer;
    data['language'] = language;
    data['gst_category'] = gstCategory;
    data['doctype'] = doctype;
    if (creditLimits != null) {
      data['credit_limits'] = creditLimits!.map((v) => v.toJson()).toList();
    }
    if (oOnload != null) {
      data['__onload'] = oOnload!.toJson();
    }
    return data;
  }
}

class CreditLimits {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? docstatus;
  int? idx;
  String? company;
  double? creditLimit;
  int? bypassCreditLimitCheck;
  String? parent;
  String? parentfield;
  String? parenttype;
  String? doctype;

  CreditLimits(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.docstatus,
      this.idx,
      this.company,
      this.creditLimit,
      this.bypassCreditLimitCheck,
      this.parent,
      this.parentfield,
      this.parenttype,
      this.doctype});

  CreditLimits.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    docstatus = json['docstatus'];
    idx = json['idx'];
    company = json['company'];
    creditLimit = json['credit_limit'];
    bypassCreditLimitCheck = json['bypass_credit_limit_check'];
    parent = json['parent'];
    parentfield = json['parentfield'];
    parenttype = json['parenttype'];
    doctype = json['doctype'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['owner'] = owner;
    data['creation'] = creation;
    data['modified'] = modified;
    data['modified_by'] = modifiedBy;
    data['docstatus'] = docstatus;
    data['idx'] = idx;
    data['company'] = company;
    data['credit_limit'] = creditLimit;
    data['bypass_credit_limit_check'] = bypassCreditLimitCheck;
    data['parent'] = parent;
    data['parentfield'] = parentfield;
    data['parenttype'] = parenttype;
    data['doctype'] = doctype;
    return data;
  }
}

class Onload {
  List<DashboardInfo>? dashboardInfo;

  Onload({this.dashboardInfo});

  Onload.fromJson(Map<String, dynamic> json) {
    if (json['dashboard_info'] != null) {
      dashboardInfo = <DashboardInfo>[];
      json['dashboard_info'].forEach((v) {
        dashboardInfo!.add(DashboardInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (dashboardInfo != null) {
      data['dashboard_info'] = dashboardInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DashboardInfo {
  double? billingThisYear;
  String? currency;
  double? totalUnpaid;
  String? company;

  DashboardInfo(
      {this.billingThisYear, this.currency, this.totalUnpaid, this.company});

  DashboardInfo.fromJson(Map<String, dynamic> json) {
    billingThisYear = json['billing_this_year'];
    currency = json['currency'];
    totalUnpaid = json['total_unpaid'];
    company = json['company'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['billing_this_year'] = billingThisYear;
    data['currency'] = currency;
    data['total_unpaid'] = totalUnpaid;
    data['company'] = company;
    return data;
  }
}
