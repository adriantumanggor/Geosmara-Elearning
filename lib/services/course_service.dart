import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';
import '../models/module.dart';
import '../models/content.dart';
import 'config.dart';

class CourseService {
  final String baseUrl;

  CourseService({this.baseUrl = AppConfig.baseUrl});

  Future<List<Course>> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/courses/'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((courseJson) => _parseCourse(courseJson)).toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  Future<Course> fetchCourseById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/courses/$id'));

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        return _parseCourse(jsonData);
      } else {
        throw Exception('Failed to load course: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course: $e');
    }
  }

  Course _parseCourse(Map<String, dynamic> json) {
    List<Module> modules = [];

    if (json['modules'] != null) {
      modules = (json['modules'] as List)
          .map((moduleJson) => _parseModule(moduleJson))
          .toList();
    }

    return Course(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      finished: json['finished'] ?? false,
      modules: modules,
    );
  }

  Module _parseModule(Map<String, dynamic> json) {
    List<String> imageUrls = [];
    List<Content> contents = [];

    if (json['image_urls'] != null) {
      imageUrls = List<String>.from(json['image_urls']);
    }

    if (json['contents'] != null) {
      contents = (json['contents'] as List)
          .map((contentJson) => _parseContent(contentJson))
          .toList();
    }

    return Module(
      id: json['id'],
      title: json['title'],
      imageUrls: imageUrls,
      contents: contents,
    );
  }

  Content _parseContent(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      text: json['text'] ?? '',
    );
  }

  // Add this method to your CourseService class
  Future<bool> updateCourseStatus(int courseId, bool finished) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/courses/$courseId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'finished': finished}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update course status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating course status: $e');
      return false;
    }
  }
}