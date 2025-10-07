import 'package:flutter/material.dart';
import '../models/study_group_model.dart';
import '../../services/database_service.dart';

class StudyGroupProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<StudyGroup> _groups = [];
  List<StudyGroup> _userGroups = [];
  bool _isLoading = false;
  String? _error;

  List<StudyGroup> get groups => _groups;
  List<StudyGroup> get userGroups => _userGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGroups() async {
    _setLoading(true);
    try {
      _groups = await _databaseService.getStudyGroups();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadUserGroups(String userId) async {
    _setLoading(true);
    try {
      _userGroups = await _databaseService.getUserGroups(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> joinGroup(int groupId, String userId) async {
    try {
      await _databaseService.joinGroup(groupId, userId);

      // Add to user groups locally
      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!_userGroups.any((g) => g.id == groupId)) {
        _userGroups.add(group);
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    try {
      await _databaseService.leaveGroup(groupId, userId);

      // Remove from user groups locally
      _userGroups.removeWhere((g) => g.id == groupId);

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required String category,
  }) async {
    try {
      final group = StudyGroup(
        name: name,
        description: description,
        category: category,
        memberCount: 1,
        createdAt: DateTime.now(),
      );

      final groupId = await _databaseService.insertStudyGroup(group);

      // Add to local lists with the generated ID
      final newGroup = StudyGroup(
        id: groupId,
        name: name,
        description: description,
        category: category,
        memberCount: 1,
        createdAt: DateTime.now(),
      );

      _groups.add(newGroup);
      _userGroups.add(newGroup);

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchGroups(String query) async {
    _setLoading(true);
    try {
      _groups = await _databaseService.searchStudyGroups(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  bool isUserInGroup(int groupId, String userId) {
    return _userGroups.any((group) => group.id == groupId);
  }

  StudyGroup? getGroupById(int groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return _userGroups.firstWhere((group) => group.id == groupId);
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
