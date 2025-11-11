import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/blog.dart';

class BlogService {
  final _supabase = Supabase.instance.client;

  // Create a new blog
  Future<Blog> createBlog({
    required String title,
    required String content,
    String? imageUrl,
    bool published = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('blogs')
          .insert({
            'user_id': userId,
            'title': title,
            'content': content,
            'image_url': imageUrl,
            'published': published,
          })
          .select()
          .single();

      return Blog.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create blog: $e');
    }
  }

  // Get all user's blogs (published and drafts)
  Future<List<Blog>> getUserBlogs() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('blogs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((blog) => Blog.fromMap(blog as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user blogs: $e');
    }
  }

  // Get published blogs (public feed)
  Future<List<Blog>> getPublishedBlogs({int limit = 50, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('blogs')
          .select()
          .eq('published', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((blog) => Blog.fromMap(blog as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch published blogs: $e');
    }
  }

  // Get a single blog by ID
  Future<Blog> getBlogById(String blogId) async {
    try {
      final response = await _supabase
          .from('blogs')
          .select()
          .eq('id', blogId)
          .single();

      return Blog.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch blog: $e');
    }
  }

  // Update a blog
  Future<Blog> updateBlog({
    required String blogId,
    required String title,
    required String content,
    String? imageUrl,
    bool? published,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final blog = await getBlogById(blogId);
      if (blog.userId != userId) {
        throw Exception('Unauthorized: You can only edit your own blogs');
      }

      final updateData = {
        'title': title,
        'content': content,
        if (imageUrl != null) 'image_url': imageUrl,
        if (published != null) 'published': published,
      };

      final response = await _supabase
          .from('blogs')
          .update(updateData)
          .eq('id', blogId)
          .select()
          .single();

      return Blog.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update blog: $e');
    }
  }

  // Delete a blog
  Future<void> deleteBlog(String blogId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final blog = await getBlogById(blogId);
      if (blog.userId != userId) {
        throw Exception('Unauthorized: You can only delete your own blogs');
      }

      // Delete image from storage if exists
      if (blog.imageUrl != null && blog.imageUrl!.isNotEmpty) {
        try {
          final imagePath = blog.imageUrl!.split('/').last;
          await _supabase.storage
              .from('avatars')
              .remove(['blog_images/$userId/$imagePath']);
        } catch (e) {
          // Continue even if image deletion fails
          print('Warning: Failed to delete blog image: $e');
        }
      }

      await _supabase.from('blogs').delete().eq('id', blogId);
    } catch (e) {
      throw Exception('Failed to delete blog: $e');
    }
  }

  // Upload blog image to avatars bucket
  Future<String> uploadBlogImage({
    required File imageFile,
    required String fileName,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final filePath = 'blog_images/$userId/$fileName';

      await _supabase.storage.from('avatars').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload blog image: $e');
    }
  }

  // Delete blog image from avatars bucket
  Future<void> deleteBlogImage(String imageUrl) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final imagePath = imageUrl.split('/').last;
      await _supabase.storage
          .from('avatars')
          .remove(['blog_images/$userId/$imagePath']);
    } catch (e) {
      throw Exception('Failed to delete blog image: $e');
    }
  }

  // Get user's blog count
  Future<int> getUserBlogCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response =
          await _supabase.rpc('get_user_blog_count', params: {'p_user_id': userId});

      return response as int;
    } catch (e) {
      throw Exception('Failed to get blog count: $e');
    }
  }

  // Get published blog count
  Future<int> getPublishedBlogCount() async {
    try {
      final response = await _supabase.rpc('get_published_blog_count');
      return response as int;
    } catch (e) {
      throw Exception('Failed to get published blog count: $e');
    }
  }

  // Get user's published blogs
  Future<List<Blog>> getUserPublishedBlogs(String userId,
      {int limit = 50, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('blogs')
          .select()
          .eq('user_id', userId)
          .eq('published', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((blog) => Blog.fromMap(blog as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user published blogs: $e');
    }
  }

  // Publish/Unpublish a blog
  Future<Blog> togglePublish(String blogId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final blog = await getBlogById(blogId);
      if (blog.userId != userId) {
        throw Exception('Unauthorized: You can only modify your own blogs');
      }

      final response = await _supabase
          .from('blogs')
          .update({'published': !blog.published})
          .eq('id', blogId)
          .select()
          .single();

      return Blog.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to toggle blog publish status: $e');
    }
  }

  // Search blogs by title (for user's own blogs)
  Future<List<Blog>> searchUserBlogs(String query) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('blogs')
          .select()
          .eq('user_id', userId)
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((blog) => Blog.fromMap(blog as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search blogs: $e');
    }
  }
}
