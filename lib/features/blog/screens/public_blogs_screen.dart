import 'package:flutter/material.dart';
import '../services/blog_service.dart';
import '../models/blog.dart';

class PublicBlogsScreen extends StatefulWidget {
  const PublicBlogsScreen({Key? key}) : super(key: key);

  @override
  State<PublicBlogsScreen> createState() => _PublicBlogsScreenState();
}

class _PublicBlogsScreenState extends State<PublicBlogsScreen> {
  final BlogService _blogService = BlogService();
  List<Blog> _blogs = [];
  bool _isLoading = true;
  int _currentPage = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() => _isLoading = true);
    try {
      final blogs = await _blogService.getPublishedBlogs(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );
      setState(() {
        if (_currentPage == 0) {
          _blogs = blogs;
        } else {
          _blogs.addAll(blogs);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _loadMore() {
    _currentPage++;
    _loadBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Blogs'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _currentPage = 0;
              _loadBlogs();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && _blogs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _blogs.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _blogs.length + 1,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    if (index == _blogs.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _loadMore,
                                child: const Text('Load More'),
                              ),
                      );
                    }

                    final blog = _blogs[index];
                    return _buildBlogCard(blog);
                  },
                ),
    );
  }

  Widget _buildBlogCard(Blog blog) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          // Navigate to blog detail
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(blog.title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          blog.imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                      const SizedBox(height: 12),
                    Text(blog.content),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview if exists
              if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    blog.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty)
                const SizedBox(height: 12),
              // Title
              Text(
                blog.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Author and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'By ${blog.authorPseudo ?? 'Anonymous'}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDate(blog.createdAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Preview
              Text(
                blog.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No blogs published yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for community blogs!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
