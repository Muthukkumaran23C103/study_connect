import 'package:flutter/material.dart';
import '../services/database_service.dart';

class PostProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _databaseService.getAllPosts();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGroupPosts(int groupId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _databaseService.getGroupPosts(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String authorId,
    int? groupId,
    required String title,
    String? content,
    List<String>? attachmentUrls,
  }) async {
    try {
      final post = Post(
        authorId: authorId,
        groupId: groupId,
        title: title,
        content: content,
        attachmentUrls: attachmentUrls?.join(','),
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final postId = await _databaseService.insertPost(post);
      final newPost = post.copyWith(id: postId);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId, String userId) async {
    try {
      await _databaseService.togglePostLike(postId, userId);

      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final isLiked = await _databaseService.isPostLiked(postId, userId);
        _posts[postIndex] = post.copyWith(
          likesCount: isLiked ? post.likesCount + 1 : post.likesCount - 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
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

  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }
}