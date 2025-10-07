import 'package:flutter/foundation.dart';
import '../../services/database_service.dart';
import '../models/post_model.dart';

class PostProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllPosts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _posts = await _databaseService.getAllPosts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGroupPosts(int groupId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _posts = await _databaseService.getGroupPosts(groupId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final post = Post(
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        groupId: groupId,
        createdAt: DateTime.now(),
      );

      final postId = await _databaseService.insertPost(post);

      // Add the new post to the local list
      final newPost = post.copyWith(id: postId);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId, String userId) async {
    try {
      await _databaseService.toggleLike(postId, userId);

      // Update the post in the local list
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final isLiked = await _databaseService.isPostLiked(postId, userId);
        final updatedPost = post.copyWith(
          likesCount: isLiked ? post.likesCount + 1 : post.likesCount - 1,
        );
        _posts[postIndex] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> isPostLiked(int postId, String userId) async {
    try {
      return await _databaseService.isPostLiked(postId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearPosts() {
    _posts.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}