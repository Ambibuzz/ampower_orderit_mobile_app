import 'dart:convert';

class ErrorLogList {
  List<ErrorLog>? errorLogList;

  ErrorLogList({this.errorLogList});

  ErrorLogList.fromJson(Map<String, dynamic> json) {
    errorLogList = List.from(json['error_log_list'])
        .map((e) => ErrorLog.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (errorLogList != null) {
      data['error_log_list'] = errorLogList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ErrorLog {
  int? id;
  String? time;
  String? version;
  String? error;
  String? exception;
  int? statusCode;

  ErrorLog({
    this.id,
    this.time,
    this.version,
    this.error,
    this.exception,
    this.statusCode,
  });

  ErrorLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    time = json['time'];
    version = json['version'];
    error = json['error'];
    exception = json['exception'];
    statusCode = json['status_code'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['time'] = time;
    data['version'] = version;
    data['error'] = error;
    data['exception'] = exception;
    data['status_code'] = statusCode;
    return data;
  }
}
