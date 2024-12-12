import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:orderit/config/styles.dart';
import 'package:orderit/config/theme.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:flutter/material.dart';

Widget imageWidget(String url, double? width, double? height, {BoxFit? fit}) {
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    placeholder: (context, url) => const Icon(Icons.error),
    errorWidget: (context, url, error) => const Icon(Icons.error),
    httpHeaders: {HttpHeaders.cookieHeader: DioHelper.cookies ?? ''},
  );
}
