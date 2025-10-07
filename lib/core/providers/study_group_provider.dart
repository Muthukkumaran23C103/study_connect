import 'package:flutter/material.dart';
import '../../core/models/study_group_model.dart';
import '../../services/database_service.dart';

class StudyGroupProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<StudyGroup> _groups = [];
  List<StudyGroup> _userGroups = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<StudyGroup> get groups => _groups;
  List<StudyGroup> get userGroups => _userGroups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadGroups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _databaseService.getStudyGroups();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserGroups(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userGroups = await _databaseService.getUserGroups(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading user groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGroup(int groupId, String userId) async {
    try {
      await _databaseService.joinGroup(groupId, userId);

      // Update local lists
      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!_userGroups.any((g) => g.id == groupId)) {
        _userGroups.add(group);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error joining group: $e';
      notifyListeners();
    }
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    try {
      await _databaseService.leaveGroup(groupId, userId);

      // Update local lists
      _userGroups.removeWhere((g) => g.id == groupId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error leaving group: $e';
      notifyListeners();
    }
  }

  Future<void> createGroup(String name, String description, String category) async {
    try {
      final group = StudyGroup(
        name: name,
        description: description,
        category: category,
        createdBy: 1, // Fixed: Use int value, not string
        memberCount: 1,
        createdAt: DateTime.now(),
      );

      final groupId = await _databaseService.insertStudyGroup(group);
      if (groupId != null) {
        final newGroup = group.copyWith(id: groupId);
        _groups.insert(0, newGroup);
        _userGroups.insert(0, newGroup);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error creating group: $e';
      notifyListeners();
    }
  }

  Future<void> searchGroups(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _databaseService.searchStudyGroups(query);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error searching groups: $e';
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