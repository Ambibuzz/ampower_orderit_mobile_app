import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/util/constants/images.dart';
import 'package:orderit/util/constants/sizes.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../orderit/views/image_widget_native.dart'
    if (dart.library.html) 'image_widget_web.dart' as image_widget;

Widget imageWidget(String url, double? width, double? height, {BoxFit? fit}) {
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    placeholder: (context, url) => Skeletonizer(
      enabled: true,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    errorWidget: (context, url, error) => Container(
      width: width,
      height: width,
      decoration: const BoxDecoration(
        borderRadius: Corners.lgBorder,
        image: DecorationImage(
          image: AssetImage(
            Images.imageNotFound,
          ),
          fit: BoxFit.cover,
        ),
      ),
    ),
    httpHeaders: {HttpHeaders.cookieHeader: DioHelper.cookies ?? ''},
  );
}
