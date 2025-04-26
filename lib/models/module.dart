import 'content.dart';

class Module {
  final dynamic id;
  final String title;
  final List<String> imageUrls;
  final List<Content> contents;

  Module({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.contents,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      title: json['title'],
      imageUrls: (json['image_urls'] as List).cast<String>(),
      contents: (json['contents'] as List)
          .map((contentJson) => Content.fromJson(contentJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_urls': imageUrls,
      'contents': contents.map((content) => content.toJson()).toList(),
    };
  }
}