import 'package:flutter/foundation.dart';
import '../models/study_group_model.dart';
import '../../services/database_service.dart';

class StudyGroupProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<StudyGroup> _groups = [];
  List<StudyGroup> _userGroups = [];
  bool _isLoading = false;
  bool _isJoining = false;
  String? _error;

  // Getters
  List<StudyGroup> get groups => _groups;
  List<StudyGroup> get userGroups => _userGroups;
  bool get isLoading => _isLoading;
  bool get isJoining => _isJoining;
  String? get error => _error;

  // Load all study groups
  Future<void> loadStudyGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await _databaseService.getStudyGroups();
    } catch (e) {
      _error = 'Failed to load study groups: $e';
      _groups = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user's groups
  Future<void> loadUserGroups(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userGroups = await _databaseService.getUserGroups(userId);
    } catch (e) {
      _error = 'Failed to load user groups: $e';
      _userGroups = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Join a study group
  Future<void> joinGroup(int groupId, int userId) async {
    _isJoining = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.joinGroup(groupId, userId);

      // Update local data
      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!_userGroups.any((g) => g.id == groupId)) {
        _userGroups.add(group);
      }

    } catch (e) {
      _error = 'Failed to join group: $e';
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }

  // Leave a study group
  Future<void> leaveGroup(int groupId, int userId) async {
    try {
      await _databaseService.leaveGroup(groupId, userId);

      // Update local data
      _userGroups.removeWhere((g) => g.id == groupId);
      notifyListeners();

    } catch (e) {
      _error = 'Failed to leave group: $e';
      notifyListeners();
    }
  }

  // Create a new study group
  Future<void> createGroup({
    required String name,
    required String description,
    required String category,
    required int createdBy,
    bool isPublic = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final group = StudyGroup(
        name: name,
        description: description,
        category: category,
        isPublic: isPublic,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      final groupId = await _databaseService.insertStudyGroup(group);

      // Add to local lists
      final newGroup = group.copyWith(id: groupId);
      _groups.insert(0, newGroup);
      _userGroups.insert(0, newGroup);

    } catch (e) {
      _error = 'Failed to create group: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search groups
  Future<void> searchGroups(String query) async {
    if (query.trim().isEmpty) {
      await loadStudyGroups();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await _databaseService.searchStudyGroups(query);
    } catch (e) {
      _error = 'Failed to search groups: $e';
      _groups = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user is member of group
  bool isMemberOfGroup(int groupId) {
    return _userGroups.any((group) => group.id == groupId);
  }

  // Get group by ID
  StudyGroup? getGroupById(int groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return _userGroups.firstWhere((group) => group.id == groupId);
    }
  }
}
