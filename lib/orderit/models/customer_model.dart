class CustomerModelList {
  List<CustomerModel>? customerList;
  CustomerModelList({this.customerList});

  CustomerModelList.fromJson(Map<String, dynamic> json) {
    customerList = List.from(json['customer_list'])
        .map((e) => CustomerModel.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (customerList != null) {
      data['customer_list'] = customerList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerModel {
  String? name;
  String? owner;
  String? creation;
  String? modified;
  String? modifiedBy;
  int? idx;
  int? docstatus;
  String? workflowState;
  String? namingSeries;
  String? customerName;
  String? customerType;
  String? gstCategory;
  String? exportType;
  String? accountManager;
  String? customerGroup;
  String? territory;
  int? soRequired;
  int? dnRequired;
  int? disabled;
  int? isInternalCustomer;
  String? defaultPriceList;
  String? defaultCurrency;
  String? language;
  String? latitudeAndLongitude;
  String? customerPrimaryContact;
  String? customerPrimaryAddress;
  String? mobileNo;
  String? emailId;
  int? isFrozen;
  double? defaultCommissionRate;
  String? doctype;
  String? primaryAddress;
  List<SalesTeam>? salesTeam;
  CustomerModel(
      {this.name,
      this.owner,
      this.creation,
      this.modified,
      this.modifiedBy,
      this.idx,
      this.docstatus,
      this.workflowState,
      this.namingSeries,
      this.customerName,
      this.customerType,
      this.gstCategory,
      this.exportType,
      this.accountManager,
      this.customerGroup,
      this.territory,
      this.soRequired,
      this.dnRequired,
      this.disabled,
      this.isInternalCustomer,
      this.defaultPriceList,
      this.language,
      this.latitudeAndLongitude,
      this.customerPrimaryContact,
      this.customerPrimaryAddress,
      this.mobileNo,
      this.emailId,
      this.isFrozen,
      this.defaultCommissionRate,
      this.doctype,
      this.defaultCurrency,
      this.primaryAddress,
      this.salesTeam});

  CustomerModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    defaultCurrency = json['default_currency'];
    owner = json['owner'];
    creation = json['creation'];
    modified = json['modified'];
    modifiedBy = json['modified_by'];
    idx = json['idx'];
    docstatus = json['docstatus'];
    workflowState = json['workflow_state'];
    namingSeries = json['naming_series'];
    customerName = json['customer_name'];
    customerType = json['customer_type'];
    gstCategory = json['gst_category'];
    exportType = json['export_type'];
    accountManager = json['account_manager'];
    customerGroup = json['customer_group'];
    territory = json['territory'];
    soRequired = json['so_required'];
    dnRequired = json['dn_required'];
    disabled = json['disabled'];
    isInternalCustomer = json['is_internal_customer'];
    defaultPriceList = json['default_price_list'];
    language = json['language'];
    latitudeAndLongitude = json['latitude_and_longitude'];
    customerPrimaryContact = json['customer_primary_contact'];
    customerPrimaryAddress = json['customer_primary_address'];
    mobileNo = json['mobile_no'];
    emailId = json['email_id'];
    isFrozen = json['is_frozen'];
    defaultCommissionRate = json['default_commission_rate'];
    doctype = json['doctype'];
    primaryAddress = json['primary_address'];
    if (json['sales_team'] != null) {
      salesTeam = <SalesTeam>[];
      json['sales_team'].forEach((v) {
        salesTeam!.add(SalesTeam.fromJson(v));
      });
    }
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
    data['workflow_state'] = workflowState;
    data['naming_series'] = namingSeries;
    data['customer_name'] = customerName;
    data['customer_type'] = customerType;
    data['gst_category'] = gstCategory;
    data['export_type'] = exportType;
    data['account_manager'] = accountManager;
    data['customer_group'] = customerGroup;
    data['territory'] = territory;
    data['so_required'] = soRequired;
    data['dn_required'] = dnRequired;
    data['disabled'] = disabled;
    data['is_internal_customer'] = isInternalCustomer;
    data['default_price_list'] = defaultPriceList;
    data['language'] = language;
    data['latitude_and_longitude'] = latitudeAndLongitude;
    data['customer_primary_contact'] = customerPrimaryContact;
    data['customer_primary_address'] = customerPrimaryAddress;
    data['mobile_no'] = mobileNo;
    data['email_id'] = emailId;
    data['is_frozen'] = isFrozen;
    data['default_commission_rate'] = defaultCommissionRate;
    data['doctype'] = doctype;
    data['default_currency'] = defaultCurrency;
    data['primary_address'] = primaryAddress;
    if (salesTeam != null) {
      data['sales_team'] = salesTeam!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SalesTeam {
  String? salesPerson;
  double? allocatedPercentage;

  SalesTeam({
    this.salesPerson,
    this.allocatedPercentage,
  });

  SalesTeam.fromJson(Map<String, dynamic> json) {
    salesPerson = json['sales_person'];
    allocatedPercentage = json['allocated_percentage'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sales_person'] = salesPerson;
    data['allocated_percentage'] = allocatedPercentage;
    return data;
  }
}
