import 'package:flutter/foundation.dart';
import '../../services/database_service.dart';
import '../models/post_model.dart';

class PostProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> loadAllPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _databaseService.getAllPosts();
      notifyListeners();
    } catch (e) {
      print('Error loading posts: $e');
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
      notifyListeners();
    } catch (e) {
      print('Error loading group posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String authorId,
    required String authorName,
    int? groupId,
    required String title,
    required String content,
    String? attachmentUrl,
  }) async {
    try {
      final post = Post(
        authorId: authorId,
        authorName: authorName,
        groupId: groupId,
        title: title,
        content: content,
        attachmentUrl: attachmentUrl,
        createdAt: DateTime.now(),
      );

      final postId = await _databaseService.insertPost(post);
      final newPost = post.copyWith(id: postId);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  Future<void> toggleLike(int postId, String userId) async {
    try {
      await _databaseService.toggleLike(postId, userId);

      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final isLiked = await _databaseService.isPostLiked(postId, userId);
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          likesCount: isLiked ? post.likesCount + 1 : post.likesCount - 1,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<bool> isPostLiked(int postId, String userId) async {
    try {
      return await _databaseService.isPostLiked(postId, userId);
    } catch (e) {
      print('Error checking if post is liked: $e');
      return false;
    }
  }

  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }
}