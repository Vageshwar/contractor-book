import 'dart:typed_data';

class SiteImage {
  final int imageId;
  final Uint8List image;
  final int siteId;

  SiteImage({required this.imageId, required this.image, required this.siteId});

  //to be used when inserting a row in the table
  Map<String, dynamic> toMapWithoutId() {
    final map = new Map<String, dynamic>();
    map["image"] = image;
    map["siteId"] = siteId;
    return map;
  }

  factory SiteImage.fromMap(Map<String, dynamic> data) => SiteImage(
        imageId: data['id'],
        image: data['image'],
        siteId: data['siteId'],
      );
}
