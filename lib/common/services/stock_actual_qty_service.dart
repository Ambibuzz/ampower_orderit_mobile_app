import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/common/models/stock_actual_qty.dart';

class StockActualQtyService extends BaseViewModel {
  double? getStockActualQty(
      String? itemCode, List<StockActualQty> stockActualQtyList) {
    var stockActualQty = 0.0;
    if (stockActualQtyList.isNotEmpty == true) {
      var stockActualQtyModel = stockActualQtyList.firstWhere(
        (element) => element.itemCode == itemCode,
        orElse: () => StockActualQty(itemCode: itemCode, actualQty: 0.0),
      );
      stockActualQty = stockActualQtyModel.actualQty!;
    }
    return stockActualQty;
  }
}
