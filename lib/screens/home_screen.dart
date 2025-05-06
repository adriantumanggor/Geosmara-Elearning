import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/course_card.dart';
import '../models/course.dart';
import '../screens/modules_screen.dart';
import '../services/course_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final List<String> bannerImages = [
    'images/gis.png',
    'images/giss.jpg',
    'images/gisss.jpg',
  ];

  int _currentPage = 0;
  bool _isLoading = true;
  List<Course> _courses = [];
  String _errorMessage = '';

  // Create instance of CourseService
  final CourseService _courseService = CourseService();

  // Key for SharedPreferences
  static const String _cachedCoursesKey = 'cached_courses';

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });

    // Load courses from cache first, then check if we need to fetch from API
    _loadCourses();
  }

  bool isDevelopmentMode = true; // Set to false in production

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      if (!isDevelopmentMode) {
        // Try to load from cache in production mode
        final cachedCourses = await _loadCoursesFromCache();
        if (cachedCourses.isNotEmpty) {
          setState(() {
            _courses = cachedCourses;
            _isLoading = false;
          });
          return; // Exit early if cache is used
        }
      }

      // Always fetch from API in development mode or if cache is empty
      await _fetchAndCacheCourses();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load courses. Please try again.';
        _isLoading = false;
      });
      print('Error loading courses: $e');
    }
  }

  // Load courses from SharedPreferences
  Future<List<Course>> _loadCoursesFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? coursesJson = prefs.getString(_cachedCoursesKey);

      if (coursesJson != null) {
        final List<dynamic> decodedList = jsonDecode(coursesJson);
        return decodedList
            .map((courseJson) => Course.fromJson(courseJson))
            .toList();
      }
    } catch (e) {
      print('Error loading courses from cache: $e');
    }

    return []; // Return empty list if cache loading fails
  }

  // Fetch courses from API and cache them
  Future<void> _fetchAndCacheCourses() async {
    try {
      final courses = await _courseService.fetchCourses();

      setState(() {
        _courses = courses;
        _isLoading = false;
      });

      // Cache the courses
      _saveCourses(courses);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load courses: $e';
        _isLoading = false;
      });
      print('Error fetching courses: $e');
    }
  }

  // Save courses to SharedPreferences
  Future<void> _saveCourses(List<Course> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert courses to a JSON string
      final List<Map<String, dynamic>> coursesMap =
      courses.map((course) => course.toJson()).toList();
      final String coursesJson = jsonEncode(coursesMap);

      // Save to SharedPreferences
      await prefs.setString(_cachedCoursesKey, coursesJson);
    } catch (e) {
      print('Error saving courses to cache: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body:SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Carousel Header Banner
              SizedBox(
                height: 270,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: bannerImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(bannerImages[index]),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            print('Error loading image: $exception');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    bannerImages.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: _currentPage == index ? 12 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.blueAccent
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),

              // Loading indicator, error message or course grid
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCourses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_courses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No courses available')),
                  )
                else
                // GridView for courses
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return CourseCard(
                        course: course,
                        onTap: () {
                          // Check if course has modules before navigating
                          if (course.modules.isNotEmpty) {
                            // Navigate to the ModulesScreen with the entire course
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModulesScreen(course: course),
                              ),
                            );
                          } else {
                            // Show a message if there are no modules
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('This course has no modules yet.'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
            ],
          ),
        ),
    );
  }
}