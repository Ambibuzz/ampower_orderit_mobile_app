import 'package:orderit/common/models/accounts_recievable_model.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:intl/intl.dart';

class ReportService {
  Future<dynamic> getAccountsRecievableReportResponse(
      String? customer, String? company) async {
    var url = '/api/method/frappe.desk.query_report.run';
    try {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var dateToday = DateFormat('yyyy-MM-dd').format(DateTime.now());

      var queryParams = {
        'report_name': 'Accounts Receivable',
        'filters':
            '{"company": "$company","report_date": "$dateToday","party_type": "Customer","party": ["$customer"],"ageing_based_on": "Due Date","range1": 30,"plant": [],"range2": 60,"range3": 90,"range4": 120,"customer_group": []}',
        'ignore_prepared_report': false,
        'are_default_filters': false,
        '_': '$timestamp'
      };
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );
      if (response?.statusCode == 200) {
        var data = response?.data;
        return data;
      }
    } catch (e) {
      exception(e, url, 'getAccountsRecievableReport');
    }
    return '';
  }

  Future<AccountsRecievable> getAccountsRecievableReport(
      String? customer, String? company) async {
    var ar = AccountsRecievable();
    var url = '/api/method/frappe.desk.query_report.run';
    try {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var dateToday = DateFormat('yyyy-MM-dd').format(DateTime.now());

      var queryParams = {
        'report_name': 'Accounts Receivable',
        'filters':
            '{"company": "$company","report_date": "$dateToday","party_type": "Customer","party": ["$customer"],"ageing_based_on": "Due Date","range1": 30,"plant": [],"range2": 60,"range3": 90,"range4": 120,"customer_group": []}',
        'ignore_prepared_report': false,
        'are_default_filters': false,
        '_': '$timestamp'
      };
      final response = await DioHelper.dio?.get(
        url,
        queryParameters: queryParams,
      );
      if (response?.statusCode == 200) {
        var data = response?.data;
        ar = AccountsRecievable.fromJson(data['message']);

        return ar;
      }
    } catch (e) {
      exception(e, url, 'getAccountsRecievableReport');
    }
    return ar;
  }
}
