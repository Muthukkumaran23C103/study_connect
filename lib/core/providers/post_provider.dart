import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../models/post_model.dart';

class PostProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<PostModel> _posts = [];  // ← FIXED: Added proper type
  bool _isLoading = false;
  String? _errorMessage;

  List<PostModel> get posts => _posts;  // ← FIXED: Added proper type
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _databaseService.getAllPosts();
    } catch (e) {
      _errorMessage = 'Failed to load posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGroupPosts(int groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _databaseService.getGroupPosts(groupId);
    } catch (e) {
      _errorMessage = 'Failed to load group posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPosts(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _databaseService.getUserPosts(userId);
    } catch (e) {
      _errorMessage = 'Failed to load user posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(PostModel post) async {
    try {
      final postId = await _databaseService.insertPost(post);
      final newPost = post.copyWith(id: postId);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create post: $e';
      notifyListeners();
    }
  }

  Future<void> updatePost(PostModel post) async {
    try {
      await _databaseService.updatePost(post);
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update post: $e';
      notifyListeners();
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _databaseService.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete post: $e';
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId, String userId) async {
    try {
      final isLiked = await _databaseService.isPostLiked(postId, userId);
      await _databaseService.toggleLike(postId, userId);

      // Update the post in the local list
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final newLikesCount = isLiked ? post.likesCount - 1 : post.likesCount + 1;
        _posts[postIndex] = post.copyWith(likesCount: newLikesCount);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle like: $e';
      notifyListeners();
    }
  }

  Future<bool> isPostLiked(int postId, String userId) async {
    try {
      return await _databaseService.isPostLiked(postId, userId);
    } catch (e) {
      return false;
    }
  }
}
