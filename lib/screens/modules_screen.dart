import 'package:flutter/material.dart';
import '../models/module.dart';
import '../models/course.dart';
import '../services/course_service.dart'; // Add this import

class ModulesScreen extends StatefulWidget {
  final Course course;

  const ModulesScreen({super.key, required this.course});

  @override
  _ModulesScreenState createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  int currentModuleIndex = 0;
  int currentContentIndex = 0;
  final CourseService _courseService = CourseService();
  bool _isUpdating = false;

  Module get currentModule => widget.course.modules[currentModuleIndex];

  // Helper function to get the appropriate image for the current content
  String getImageForCurrentContent() {
    // If there are no images at all, return an empty string
    if (currentModule.imageUrls.isEmpty) {
      return '';
    }

    // If we have an image for the current content, use it
    if (currentContentIndex < currentModule.imageUrls.length) {
      return currentModule.imageUrls[currentContentIndex];
    }

    // Otherwise, use the last available image
    return currentModule.imageUrls.last;
  }

  // Calculate overall progress across all modules and their contents
  double calculateProgress() {
    int totalContents = 0;
    int completedContents = 0;

    // Count total contents across all modules
    for (int i = 0; i < widget.course.modules.length; i++) {
      totalContents += widget.course.modules[i].contents.length;

      // Count completed contents
      if (i < currentModuleIndex) {
        // All contents in previous modules are completed
        completedContents += widget.course.modules[i].contents.length;
      } else if (i == currentModuleIndex) {
        // Count contents completed in current module
        completedContents += currentContentIndex + 1;
      }
    }

    return totalContents > 0 ? completedContents / totalContents : 0.0;
  }

  // Method to update course completion status in the database
  Future<bool> _updateCourseStatus() async {
    try {
      setState(() {
        _isUpdating = true;
      });

      // Add code to update the database
      return await _courseService.updateCourseStatus(widget.course.id, true);
    } catch (e) {
      print('Error updating course status: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void moveNext() async {
    if (currentContentIndex < currentModule.contents.length - 1) {
      // Move to next content in current module
      setState(() {
        currentContentIndex++;
      });
    } else if (currentModuleIndex < widget.course.modules.length - 1) {
      // Move to first content of next module
      setState(() {
        currentModuleIndex++;
        currentContentIndex = 0;
      });
    } else {
      // Finished all modules - update in database before proceeding
      final success = await _updateCourseStatus();

      if (success) {
        setState(() {
          widget.course.finished = true;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update course status. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.course.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: calculateProgress(),
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            // Module Title
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Center(
                child: Text(
                  currentModule.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Voltaire-Frangela',
                  ),
                ),
              ),
            ),

            // Image if available
            if (currentModule.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  getImageForCurrentContent(),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text('Image not available'),
                      ),
                    );
                  },
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 32),
              child: currentModule.contents.isNotEmpty
                  ? Text(
                currentModule.contents[currentContentIndex].text,
                style: const TextStyle(fontSize: 16, height: 1.6),
              )
                  : const Text(
                'No content available',
                style: TextStyle(fontSize: 16, height: 1.6),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ElevatedButton(
          onPressed: _isUpdating ? null : moveNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 3,
            disabledBackgroundColor: Colors.blue.withOpacity(0.6),
          ),
          child: _isUpdating
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "UPDATING...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
              : Text(
            isLastContent && isLastModule ? "FINISH" : "NEXT",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  bool get isLastContent => currentContentIndex == currentModule.contents.length - 1;
  bool get isLastModule => currentModuleIndex == widget.course.modules.length - 1;
}