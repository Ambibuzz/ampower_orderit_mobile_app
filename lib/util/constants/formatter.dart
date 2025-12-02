import 'package:orderit/locators/locator.dart';
import 'package:intl/intl.dart';
import 'package:orderit/orderit/viewmodels/items_viewmodel.dart';

class Formatter {
  // currency formatter
  static final formatter = NumberFormat.currency(
    locale: 'en_IN',
    decimalDigits: 2,
    symbol: locator.get<ItemsViewModel>().currentCurrency.symbol ?? '₹',
    //  '₹',
  );

  static NumberFormat customFormatter(String? symbol) {
    return NumberFormat.currency(
      locale: 'en_IN',
      decimalDigits: 2,
      symbol: symbol ?? '',
      //  '₹',
    );
  }
}
