import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../../services/database_service.dart';

class PostProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _error;

  // Getters
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get error => _error;

  // Load posts (all or by group)
  Future<void> loadPosts({int? groupId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _databaseService.getPosts(groupId: groupId);
    } catch (e) {
      _error = 'Failed to load posts: $e';
      _posts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new post
  Future<void> createPost({
    required int groupId,
    required int authorId,
    String? title,
    required String content,
    String postType = 'general',
    List<String> attachmentUrls = const [],
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final post = Post(
        groupId: groupId,
        authorId: authorId,
        title: title,
        content: content,
        postType: postType,
        attachmentUrls: attachmentUrls,
        createdAt: DateTime.now(),
      );

      final postId = await _databaseService.insertPost(post);

      // Add to local list
      final newPost = post.copyWith(id: postId);
      _posts.insert(0, newPost); // Add to beginning

    } catch (e) {
      _error = 'Failed to create post: $e';
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // Like/unlike a post
  Future<void> toggleLike(int postId, int userId) async {
    try {
      await _databaseService.likePost(postId, userId);

      // Update local post
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
      _error = 'Failed to toggle like: $e';
      notifyListeners();
    }
  }

  // Search posts
  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      await loadPosts(); // Load all posts
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _databaseService.searchPosts(query);
    } catch (e) {
      _error = 'Failed to search posts: $e';
      _posts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh posts
  Future<void> refreshPosts({int? groupId}) async {
    _posts.clear();
    await loadPosts(groupId: groupId);
  }

  // Clear posts
  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }
}
