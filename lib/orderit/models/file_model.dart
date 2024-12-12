class FilesList {
  List<FileModelOrderIT>? filesList;
  FilesList({this.filesList});

  FilesList.fromJson(Map<String, dynamic> json) {
    filesList = List.from(json['files_list'])
        .map((e) => FileModelOrderIT.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (filesList != null) {
      data['files_list'] = filesList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FileModelOrderIT {
  String? fileUrl;
  String? fileName;
  String? attachedToName;
  int? isPrivate;

  FileModelOrderIT({
    this.fileUrl,
    this.fileName,
    this.attachedToName,
    this.isPrivate,
  });

  FileModelOrderIT.fromJson(Map<String, dynamic> json) {
    fileUrl = json['file_url'];
    fileName = json['file_name'];
    attachedToName = json['attached_to_name'];
    isPrivate = json['is_private'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['file_url'] = fileUrl;
    data['file_name'] = fileName;
    data['attached_to_name'] = attachedToName;
    data['is_private'] = isPrivate;
    return data;
  }
}
