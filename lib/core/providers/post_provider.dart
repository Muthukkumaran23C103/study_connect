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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _databaseService.getAllPosts();
    } catch (e) {
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    int? groupId,
    List<String>? attachments,
  }) async {
    try {
      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch,
        authorId: authorId,
        authorName: authorName,
        title: title,
        content: content,
        timestamp: DateTime.now(),
        groupId: groupId,
        attachments: attachments ?? [],
        likesCount: 0,
        commentsCount: 0,
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
      final isLiked = await _databaseService.isPostLiked(postId, userId);
      await _databaseService.toggleLike(postId, userId);

      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
