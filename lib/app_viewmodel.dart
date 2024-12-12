import 'package:orderit/base_viewmodel.dart';
import 'package:flutter/material.dart';

class AppViewModel extends BaseViewModel {
  Color? primaryColor;
  Color? convertedColor;

  Future<Color?> colorConvert(String colorData) async {
    colorData = colorData.replaceAll('#', '');
    Color? converted;
    if (colorData.length == 6) {
      converted = Color(int.parse('0xFF$colorData'));
    } else {
      converted = Color(int.parse(colorData));
    }
    return converted;
  }
}
