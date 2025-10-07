import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../../services/database_service.dart';

class PostProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllPosts() async {
    _setLoading(true);
    try {
      _posts = await _databaseService.getAllPosts();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadGroupPosts(int groupId) async {
    _setLoading(true);
    try {
      _posts = await _databaseService.getGroupPosts(groupId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> createPost({
    required String content,
    required String authorId,
    required String authorName,
    int? groupId,
    String? attachmentUrl,
  }) async {
    try {
      final post = Post(
        content: content,
        authorId: authorId,
        authorName: authorName,
        groupId: groupId,
        createdAt: DateTime.now(),
        attachmentUrl: attachmentUrl,
      );

      final postId = await _databaseService.insertPost(post);

      // Add to local list with the generated ID
      _posts.insert(0, Post(
        id: postId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        groupId: groupId,
        createdAt: DateTime.now(),
        attachmentUrl: attachmentUrl,
      ));

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId, String userId) async {
    try {
      await _databaseService.togglePostLike(postId, userId);

      // Update local post
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          likesCount: post.likesCount, // This will be updated by database trigger
        );
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
