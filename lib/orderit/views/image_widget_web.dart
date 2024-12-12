import 'package:orderit/common/widgets/abstract_factory/iwidgetsfactory.dart';
import 'package:flutter/material.dart';

Widget imageWidget(String url, double width, double height, {BoxFit? fit}) {
  return Image.network(
    url,
    fit: fit,
    width: width,
    height: height,
    loadingBuilder: (context, child, loadingProgress) =>
        WidgetsFactoryList.circularProgressIndicator(),
    errorBuilder: (context, url, error) => const Icon(Icons.error),
  );
}
