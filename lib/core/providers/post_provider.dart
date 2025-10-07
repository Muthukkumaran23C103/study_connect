import 'package:flutter/material.dart';
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
      );

      final postId = await _databaseService.insertPost(post);

      // Add to local list
      _posts.insert(0, post.copyWith(id: postId));
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

      // Update local post
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final updatedLikes = List<String>.from(post.likes);

        if (isLiked) {
          updatedLikes.remove(userId);
        } else {
          updatedLikes.add(userId);
        }

        _posts[postIndex] = post.copyWith(likes: updatedLikes);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}