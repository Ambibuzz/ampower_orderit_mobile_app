class AccountsRecievable {
  List<AccountsRecievableResult>? result;
  List<AccountsRecievableColumns>? columns;
  AccountsRecievableChart? chart;

  AccountsRecievable({
    this.result,
    this.columns,
    this.chart,
  });

  AccountsRecievable.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <AccountsRecievableResult>[];
      json['result'].forEach((v) {
        if (v is Map<String, dynamic>) result!.add(AccountsRecievableResult.fromJson(v));
      });
    }
    if (json['columns'] != null) {
      columns = <AccountsRecievableColumns>[];
      json['columns'].forEach((v) {
        columns!.add(AccountsRecievableColumns.fromJson(v));
      });
    }
    chart = json['chart'] != null ? AccountsRecievableChart.fromJson(json['chart']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (columns != null) {
      data['columns'] = columns!.map((v) => v.toJson()).toList();
    }
    if (chart != null) {
      data['chart'] = chart!.toJson();
    }
    return data;
  }
}

class AccountsRecievableResult {
  String? voucherNo;
  double? paidInAccountCurrency;
  String? dueDate;
  double? range1;
  double? range2;
  double? range3;
  double? range4;
  double? range5;

  AccountsRecievableResult({
    this.voucherNo,
    this.paidInAccountCurrency,
    this.dueDate,
    this.range1,
    this.range2,
    this.range3,
    this.range4,
    this.range5,
  });

  AccountsRecievableResult.fromJson(Map<String, dynamic> json) {
    voucherNo = json['voucher_no'];
    paidInAccountCurrency = json['paid_in_account_currency'];
    dueDate = json['due_date'];
    range1 = json['range1'];
    range2 = json['range2'];
    range3 = json['range3'];
    range4 = json['range4'];
    range5 = json['range5'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['voucher_no'] = voucherNo;
    data['paid_in_account_currency'] = paidInAccountCurrency;
    data['due_date'] = dueDate;
    data['range1'] = range1;
    data['range2'] = range2;
    data['range3'] = range3;
    data['range4'] = range4;
    data['range5'] = range5;
    return data;
  }
}

class AccountsRecievableColumns {
  String? label;
  String? fieldname;
  String? fieldtype;
  String? options;
  int? width;

  AccountsRecievableColumns(
      {this.label, this.fieldname, this.fieldtype, this.options, this.width});

  AccountsRecievableColumns.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    fieldname = json['fieldname'];
    fieldtype = json['fieldtype'];
    options = json['options'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['label'] = label;
    data['fieldname'] = fieldname;
    data['fieldtype'] = fieldtype;
    data['options'] = options;
    data['width'] = width;
    return data;
  }
}

class AccountsRecievableChart {
  AccountsRecievableData? data;
  String? type;

  AccountsRecievableChart({this.data, this.type});

  AccountsRecievableChart.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? AccountsRecievableData.fromJson(json['data']) : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['type'] = type;
    return data;
  }
}

class AccountsRecievableData {
  List<String>? labels;
  List<AccountsRecievableDatasets>? datasets;
  AccountsRecievableData({this.labels, this.datasets});

  AccountsRecievableData.fromJson(Map<String, dynamic> json) {
    labels = json['labels'].cast<String>();
    if (json['datasets'] != null) {
      datasets = <AccountsRecievableDatasets>[];
      json['datasets'].forEach((v) {
        datasets!.add(AccountsRecievableDatasets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['labels'] = labels;
    if (datasets != null) {
      data['datasets'] = datasets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AccountsRecievableDatasets {
  List<double>? values;
  AccountsRecievableDatasets({this.values});

  AccountsRecievableDatasets.fromJson(Map<String, dynamic> json) {
    values = json['values'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['values'] = values;
    return data;
  }
}
