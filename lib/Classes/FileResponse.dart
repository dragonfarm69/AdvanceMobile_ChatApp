class FileResponse {
  List<FileInfo>? files;
  
  FileResponse({this.files});
  
  factory FileResponse.fromJson(Map<String, dynamic> json) {
    return FileResponse(
      files: json['files'] != null 
          ? List<FileInfo>.from(json['files'].map((x) => FileInfo.fromJson(x)))
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'files': files?.map((x) => x.toJson()).toList(),
    };
  }
}

class FileInfo {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? name;
  String? extension;
  String? mimeType;
  int? size;
  String? owner;
  String? url;
  
  FileInfo({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.extension,
    this.mimeType,
    this.size,
    this.owner,
    this.url,
  });
  
  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      id: json['id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      name: json['name'],
      extension: json['extension'],
      mimeType: json['mime_type'],
      size: json['size'],
      owner: json['owner'],
      url: json['url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'name': name,
      'extension': extension,
      'mime_type': mimeType,
      'size': size,
      'owner': owner,
      'url': url,
    };
  }
}