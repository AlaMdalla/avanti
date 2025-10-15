import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<Profile> createProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? pseudo,
    String? avatarUrl,
    String? phone,
  }) async {
    final response = await _supabase.from('profiles').insert({
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'pseudo': pseudo,
      'avatar_url': avatarUrl,
      'phone': phone,
    }).select().single();

    return Profile.fromJson(response);
  }

  Future<Profile> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? pseudo,
    String? avatarUrl,
    String? phone,
    
  }) async {
    final response = await _supabase
        .from('profiles')
        .update({
          'first_name': firstName,
          'last_name': lastName,
          'pseudo': pseudo,
          'avatar_url': avatarUrl,
          'phone': phone,
        })
        .eq('user_id', userId)
        .select()
        .single();

    return Profile.fromJson(response);
  }

  Future<String?> uploadAvatar(File imageFile, String userId) async {
    try {
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      await _supabase.storage
          .from('avatars')
          .upload(fileName, imageFile);

      final imageUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  Future<bool> deleteAvatar(String avatarUrl) async {
    try {
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 2) {
        final fileName = pathSegments.last;
        
        await _supabase.storage
            .from('avatars')
            .remove([fileName]);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting avatar: $e');
      return false;
    }
  }
}