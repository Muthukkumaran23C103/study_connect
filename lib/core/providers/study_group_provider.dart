import 'package:flutter/material.dart';
import '../services/database_service.dart';

class StudyGroupProvider with ChangeNotifier {
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
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _databaseService.getStudyGroups();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserGroups(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userGroups = await _databaseService.getUserGroups(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGroup(int groupId, String userId) async {
    try {
      await _databaseService.joinGroup(groupId, userId);

      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!_userGroups.any((g) => g.id == groupId)) {
        _userGroups.add(group);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    try {
      await _databaseService.leaveGroup(groupId, userId);

      _userGroups.removeWhere((g) => g.id == groupId);
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
    required String createdBy,
  }) async {
    try {
      final group = StudyGroup(
        name: name,
        description: description,
        category: category,
        createdBy: int.parse(createdBy),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final groupId = await _databaseService.insertStudyGroup(group);
      final newGroup = group.copyWith(id: groupId);
      _groups.add(newGroup);
      _userGroups.add(newGroup);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchGroups(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _databaseService.searchStudyGroups(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}