import 'package:orderit/base_viewmodel.dart';
import 'package:orderit/util/helpers.dart';

class SuccessViewModel extends BaseViewModel {
  // share file
  Future<void> shareFile(String? path, String title, String text) async {
    if (path != null) {
      await fileShare(path, title, text);
    }
  }
}
