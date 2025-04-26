import 'package:flutter/material.dart';
import '../widgets/course_card.dart';
import '../models/course.dart';
import '../screens/modules_screen.dart';
import '../services/course_service.dart'; // Add this import for the service

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

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });

    // Fetch courses when screen loads
    _fetchCourses();
  }

  // Method to fetch courses from API
  Future<void> _fetchCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final courses = await _courseService.fetchCourses();

      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load courses: $e';
        _isLoading = false;
      });
      print('Error fetching courses: $e');
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
      body: RefreshIndicator(
        onRefresh: _fetchCourses,
        child: SingleChildScrollView(
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
                        onPressed: _fetchCourses,
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
      ),
    );
  }
}