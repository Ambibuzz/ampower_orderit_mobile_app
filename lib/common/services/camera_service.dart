import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:orderit/common/widgets/custom_toast.dart';
import 'package:orderit/config/colors.dart';
import 'package:orderit/config/exception.dart';
import 'package:orderit/util/dio_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CameraService {
  late CameraController _cameraController;
  CameraController get cameraController => _cameraController;

  String? _imagePath;
  String? get imagePath => _imagePath;

  Future<void> initialize() async {
    var description = await _getCameraDescription();
    await _setupCameraController(description);
    // this._cameraRotation = rotationIntToImageRotation(
    //   description.sensorOrientation,
    // );
  }

  Future<CameraDescription> _getCameraDescription() async {
    var cameras = await availableCameras();
    return cameras.firstWhere((CameraDescription camera) =>
        camera.lensDirection == CameraLensDirection.front);
  }

  Future _setupCameraController(
    CameraDescription description,
  ) async {
    _cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController.initialize();
  }

  Future<XFile> takePicture() async {
    await _cameraController.stopImageStream();
    var file = await _cameraController.takePicture();
    _imagePath = file.path;
    return file;
  }

  Size getImageSize() {
    assert(_cameraController.value.previewSize != null, 'Preview size is null');
    return Size(
      _cameraController.value.previewSize!.height,
      _cameraController.value.previewSize!.width,
    );
  }

  Future dispose() async {
    await _cameraController.dispose();
  }

  Future uploadImage(BuildContext context, String imgData, File file,
      int isPrivate, String? doctype, String? docname) async {
    try {
      var fileName = file.path.split('/').last;
      var formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'docname': docname,
        'doctype': doctype,
        'is_private': isPrivate,
        'folder': 'Home/Attachments'
      });

      var response = await DioHelper.dio?.post(
        '/api/method/upload_file',
        data: formData,
      );
      if (response?.statusCode == 200) {
        var finalData = response?.data;
        return await finalData;
      } else {
        await flutterSimpleToast(Colors.white, Colors.black,
            'Couldnt Upload Image. Please try again');
      }
      // */
    } catch (e) {
      exception(e, '/api/method/upload_file', 'uploadImage');
    }
  }
}
