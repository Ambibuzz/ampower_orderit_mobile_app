import 'package:orderit/base_viewmodel.dart';

class ImageViewerViewModel extends BaseViewModel {
  int currentIndex = 0;
  void onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }
}