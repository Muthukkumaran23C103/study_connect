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
    List<String>? attachmentUrls,
  }) async {
    try {
      final post = Post(
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        groupId: groupId,
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        attachmentUrls: attachmentUrls ?? [],
      );

      final postId = await _databaseService.insertPost(post);

      final newPost = post.copyWith(id: postId);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId, String userId) async {
    try {
      final isCurrentlyLiked = await _databaseService.isPostLiked(postId, userId);
      await _databaseService.toggleLike(postId, userId);

      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          likesCount: isCurrentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
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
      return false;
    }
  }

  void clearPosts() {
    _posts.clear();
    notifyListeners();
  }
}