import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../models/study_group_model.dart';

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
    } catch (e) {
      _errorMessage = 'Failed to load groups: $e';
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
    } catch (e) {
      _errorMessage = 'Failed to load user groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGroup(int groupId, String userId) async {
    try {
      await _databaseService.joinGroup(groupId.toString(), userId);

      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!_userGroups.any((g) => g.id == groupId)) {
        _userGroups.add(group);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to join group: $e';
      notifyListeners();
    }
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    try {
      await _databaseService.leaveGroup(groupId.toString(), userId);

      _userGroups.removeWhere((g) => g.id == groupId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to leave group: $e';
      notifyListeners();
    }
  }

  Future<void> createGroup(String name, String description, String category) async {
    try {
      final group = StudyGroup(
        name: name,
        description: description,
        category: category,
        createdBy: 1, // Replace with actual user ID as int
        memberCount: 1,
      );

      final groupId = await _databaseService.insertStudyGroup(group);

      final newGroup = group.copyWith(id: groupId);
      _groups.add(newGroup);
      _userGroups.add(newGroup);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create group: $e';
      notifyListeners();
    }
  }

  Future<void> searchGroups(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _databaseService.searchStudyGroups(query);
    } catch (e) {
      _errorMessage = 'Failed to search groups: $e';
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