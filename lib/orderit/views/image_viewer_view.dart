import 'dart:io';
import 'package:orderit/base_view.dart';
import 'package:orderit/common/services/storage_service.dart';
import 'package:orderit/common/widgets/common.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/locators/locator.dart';
import 'package:orderit/orderit/models/file_model.dart';
import 'package:orderit/orderit/viewmodels/image_viewer_viewmodel.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/display_helper.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:orderit/util/dio_helper.dart';

class ImageViewerView extends StatefulWidget {
  final List<FileModelOrderIT>? images;
  final int initialIndex;

  const ImageViewerView({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewerView> {
  late final PageController _pageController;
  late final PhotoViewController _photoViewController;

  @override
  Widget build(BuildContext context) {
    return BaseView<ImageViewerViewModel>(
      onModelReady: (model) {
        model.currentIndex = widget.initialIndex;
        _pageController = PageController(initialPage: model.currentIndex);
        _photoViewController = PhotoViewController();
      },
      onModelClose: (model) {
        _pageController.dispose();
        _photoViewController.dispose();
      },
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: Common.commonAppBar('Image Detail', [], context),
          body: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: _pageController,
            itemCount: widget.images?.length,
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                errorBuilder: (context, error, stackTrace) => Container(
                  width: displayWidth(context) * 0.5,
                  height: displayWidth(context) * 0.5,
                  decoration: const BoxDecoration(
                    borderRadius: Corners.lgBorder,
                    image: DecorationImage(
                      image: AssetImage(
                        Images.imageNotFound,
                      ),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                imageProvider: NetworkImage(
                  '${locator.get<StorageService>().apiUrl}${widget.images![index].fileUrl}',
                  headers: {HttpHeaders.cookieHeader: DioHelper.cookies ?? ''},
                ),
                controller: _photoViewController,
                initialScale: PhotoViewComputedScale.contained * 0.8,
                // minScale: PhotoViewComputedScale.contained * 0.8,
                // maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: widget.images![index]),
              );
            },
            onPageChanged: model.onPageChanged,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}