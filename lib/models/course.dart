import 'module.dart';

class Course {
  final dynamic id;
  final String title;
  final String imageUrl;
  final List<Module> modules;
  bool finished;

  Course({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.modules,
    this.finished = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      modules: (json['modules'] as List)
          .map((moduleJson) => Module.fromJson(moduleJson))
          .toList(),
      finished: json['finished'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'modules': modules.map((module) => module.toJson()).toList(),
      'finished': finished,
    };
  }
}