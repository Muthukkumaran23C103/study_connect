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
    _setLoading(true);
    try {
      _posts = await _databaseService.getAllPosts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadGroupPosts(int groupId) async {
    _setLoading(true);
    try {
      _posts = await _databaseService.getGroupPosts(groupId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
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
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        groupId: groupId,
      );

      final postId = await _databaseService.insertPost(post);

      // Add the new post to the local list with the generated ID
      final newPost = Post(
        id: postId,
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        groupId: groupId,
      );

      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId, String userId) async {
    try {
      final isLiked = await _databaseService.isPostLiked(postId, userId);
      await _databaseService.toggleLike(postId, userId);

      // Update the local post
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final updatedPost = Post(
          id: post.id,
          title: post.title,
          content: post.content,
          authorId: post.authorId,
          authorName: post.authorName,
          createdAt: post.createdAt,
          likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
          commentsCount: post.commentsCount,
          groupId: post.groupId,
        );
        _posts[postIndex] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}