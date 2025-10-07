import 'package:flutter/material.dart';
import '../../core/models/post_model.dart';
import '../../services/database_service.dart';

class PostProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _databaseService.getAllPosts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading posts: $e';
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
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading group posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
    int? groupId,
    List<String>? attachmentUrls,
  }) async {
    try {
      final post = Post(
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        groupId: groupId,
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      final postId = await _databaseService.insertPost(post);
      if (postId != null) {
        final newPost = post.copyWith(id: postId);
        _posts.insert(0, newPost);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error creating post: $e';
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
        final isLiked = await _databaseService.isPostLiked(postId, userId);

        final newLikesCount = isLiked ? post.likesCount + 1 : post.likesCount - 1;
        _posts[postIndex] = post.copyWith(likesCount: newLikesCount);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error toggling like: $e';
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