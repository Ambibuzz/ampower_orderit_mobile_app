import 'package:intl/intl.dart';

class Formatter {
  // currency formatter
  static final formatter = NumberFormat.currency(
    locale: 'en_IN',
    decimalDigits: 2,
    symbol: '₹',
  );
}
