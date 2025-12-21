class imageInfo {
  String id;
  String url;

  imageInfo({
    required this.id,
    required this.url
  });

  factory imageInfo.fromJson(Map<String, dynamic> json) {
    return imageInfo(
      id: json['id'],
      url: json['url'],
    );
  }
}
