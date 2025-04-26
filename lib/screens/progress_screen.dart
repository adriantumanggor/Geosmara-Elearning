import 'package:flutter/material.dart';
import '../widgets/course_card.dart';
import '../models/course.dart';
import '../screens/modules_screen.dart';
import '../services/course_service.dart'; // Add this import for the service

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;
  List<Course> _finishedCourses = [];
  String _errorMessage = '';

  // Create instance of CourseService
  final CourseService _courseService = CourseService();

  @override
  void initState() {
    super.initState();
    // Fetch courses when screen loads
    _fetchFinishedCourses();
  }

  // Method to fetch finished courses from API
  Future<void> _fetchFinishedCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Fetch all courses and filter the completed ones
      final courses = await _courseService.fetchCourses();
      final finishedCourses = courses.where((course) => course.finished).toList();

      setState(() {
        _finishedCourses = finishedCourses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load courses: $e';
        _isLoading = false;
      });
      print('Error fetching finished courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchFinishedCourses,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchFinishedCourses,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
              : _finishedCourses.isEmpty
              ? const Center(
            child: Text(
              'No completed courses yet',
              style: TextStyle(fontSize: 16),
            ),
          )
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: _finishedCourses.length,
                itemBuilder: (context, index) {
                  final course = _finishedCourses[index];
                  return CourseCard(
                    course: course,
                    showCompletionBadge: true, // Always show badge for completed courses
                    onTap: () {
                      if (course.modules.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModulesScreen(course: course),
                          ),
                        );
                      } else {
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
            ),
          ),
        ),
      ),
    );
  }
}