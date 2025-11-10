import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import '../services/course_recommendation_service.dart';
import 'course_view_screen.dart';

class CourseRecommendationScreen extends StatefulWidget {
  const CourseRecommendationScreen({super.key});

  @override
  State<CourseRecommendationScreen> createState() => _CourseRecommendationScreenState();
}

class _CourseRecommendationScreenState extends State<CourseRecommendationScreen> {
  final _courseService = CourseService();
  final _recommendationService = CourseRecommendationService();
  final _queryCtrl = TextEditingController();
  List<Course> _allCourses = [];
  List<CourseRecommendation> _recommendations = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _courseService.list();
      setState(() => _allCourses = courses);
    } catch (e) {
      setState(() => _error = 'Failed to load courses: $e');
    }
  }

  Future<void> _searchRecommendations() async {
    final query = _queryCtrl.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Please enter a search query');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final recommendations = await _recommendationService.recommendCourses(
        userQuery: query,
        availableCourses: _allCourses,
        limit: 10,
      );

      setState(() {
        _recommendations = recommendations;
        if (recommendations.isEmpty) {
          _error = 'No matching courses found';
        }
      });
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _getAIRecommendations() async {
    final interests = _queryCtrl.text.trim();
    if (interests.isEmpty) {
      setState(() => _error = 'Please describe your interests');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _recommendationService.getAIRecommendations(
        userInterests: interests,
        availableCourses: _allCourses,
      );

      setState(() {
        _recommendations = result.recommendations;
        if (result.recommendations.isEmpty) {
          _error = result.explanation;
        }
      });

      if (mounted && result.recommendations.isNotEmpty) {
        _showExplanationDialog(result.explanation);
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _getSimilarCourses(Course course) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final recommendations = await _recommendationService.getSimilarCourses(
        referenceCourse: course,
        availableCourses: _allCourses,
        limit: 5,
      );

      setState(() => _recommendations = recommendations);
      _queryCtrl.text = 'Similar to: ${course.title}';
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showExplanationDialog(String explanation) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('AI Recommendation Details'),
        content: SingleChildScrollView(child: Text(explanation)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Recommendations'), elevation: 0),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _queryCtrl,
                  decoration: InputDecoration(
                    hintText: 'Describe your interests or search query...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _searchRecommendations(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _searchRecommendations,
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _getAIRecommendations,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AI'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _recommendations.isEmpty
                    ? Center(
                        child: Text(
                          _error == null ? 'Enter a query to get started' : '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _recommendations.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final rec = _recommendations[index];
                          return _RecommendationCard(
                            recommendation: rec,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CourseViewScreen(courseId: rec.course.id),
                                ),
                              );
                            },
                            onSimilar: () => _getSimilarCourses(rec.course),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final CourseRecommendation recommendation;
  final VoidCallback onTap;
  final VoidCallback onSimilar;

  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
    required this.onSimilar,
  });

  @override
  Widget build(BuildContext context) {
    final course = recommendation.course;
    final scorePercent = (recommendation.score * 100).toStringAsFixed(0);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  course.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _CourseIcon(),
                ),
              )
            else
              const _CourseIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (course.description != null)
                    Text(
                      course.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recommendation.reason,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$scorePercent%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_new_outlined, size: 20),
                  onPressed: onTap,
                  tooltip: 'View course',
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 20),
                  onPressed: onSimilar,
                  tooltip: 'Similar courses',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseIcon extends StatelessWidget {
  const _CourseIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.school_outlined, color: Theme.of(context).primaryColor, size: 30),
    );
  }
}
