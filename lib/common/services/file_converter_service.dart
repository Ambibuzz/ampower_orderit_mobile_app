import 'dart:convert';
import 'dart:io';

class FileConverter {
  static String getBase64FormateFile(String path) {
    var file = File(path);
    List<int> fileInByte = file.readAsBytesSync();
    var fileInBase64 = base64Encode(fileInByte);
    return fileInBase64;
  }
}
