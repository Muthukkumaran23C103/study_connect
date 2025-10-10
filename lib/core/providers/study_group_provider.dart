import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../models/study_group_model.dart';

class StudyGroupProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<StudyGroupModel> _studyGroups = [];
  List<StudyGroupModel> _userGroups = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<StudyGroupModel> get studyGroups => _studyGroups;
  List<StudyGroupModel> get groups => _studyGroups;
  List<StudyGroupModel> get userGroups => _userGroups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all study groups
  Future<void> loadStudyGroups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _studyGroups = await _databaseService.getStudyGroups();
    } catch (e) {
      _errorMessage = 'Failed to load groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load study groups for a specific user
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

  // Join a study group
  Future<void> joinGroup(int groupId, String userId) async {
    try {
      await _databaseService.joinGroup(groupId, userId);
      final group = _studyGroups.firstWhere((g) => g.id == groupId);
      if (!_userGroups.any((g) => g.id == groupId)) {
        _userGroups.add(group);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to join group: $e';
      notifyListeners();
    }
  }

  // Leave a study group
  Future<void> leaveGroup(int groupId, String userId) async {
    try {
      await _databaseService.leaveGroup(groupId, userId);
      _userGroups.removeWhere((g) => g.id == groupId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to leave group: $e';
      notifyListeners();
    }
  }

  // Create a new study group
  Future<void> createGroup(String name, String description, String category, String createdBy) async {
    try {
      final group = StudyGroupModel(
        name: name,
        description: description,
        createdBy: createdBy,
        tags: category,
        memberCount: 1,
        createdAt: DateTime.now(),
      );

      final groupId = await _databaseService.insertStudyGroup(group);
      final newGroup = group.copyWith(id: groupId);
      _studyGroups.add(newGroup);
      _userGroups.add(newGroup);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create group: $e';
      notifyListeners();
    }
  }

  // Search study groups
  Future<void> searchGroups(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _studyGroups = await _databaseService.searchStudyGroups(query);
    } catch (e) {
      _errorMessage = 'Failed to search groups: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user is in group
  bool isUserInGroup(int groupId, String userId) {
    return _userGroups.any((group) => group.id == groupId);
  }

  // Get group by ID
  StudyGroupModel? getGroupById(int groupId) {
    try {
      return _studyGroups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      try {
        return _userGroups.firstWhere((group) => group.id == groupId);
      } catch (e) {
        return null;
      }
    }
  }
}
