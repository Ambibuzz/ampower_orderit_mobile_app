import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/locators/locator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../orderit/views/image_widget_native.dart'
    if (dart.library.html) 'image_widget_web.dart' as image_widget;

class StackedImages extends StatelessWidget {
  final List<String> imageUrls;
  bool isImageLoading;

  StackedImages(
      {super.key, required this.imageUrls, required this.isImageLoading});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isImageLoading,
      child: SizedBox(
        width: 80, // Adjust width based on your UI needs
        height: 40,
        child: Stack(
          children: List.generate(imageUrls.length, (index) {
            if (index >= 3) return const SizedBox(); // Show only 3 images max
            return Positioned(
              left: index * 15.0,
              // Adjust overlap
              child: ClipRRect(
                borderRadius: Corners.medBorder,
                child: image_widget.imageWidget(
                    '${locator.get<StorageService>().apiUrl}${imageUrls[index]}',
                    40,
                    40),
              ),
            );
          }),
        ),
      ),
    );
  }
}