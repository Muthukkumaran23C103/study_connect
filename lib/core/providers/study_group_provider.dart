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
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _groups = await _databaseService.getStudyGroups();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserGroups(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _userGroups = await _databaseService.getUserGroups(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGroup(int groupId, String userId) async {
    try {
      await _databaseService.joinGroup(groupId, userId);

      // Update local state
      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!_userGroups.any((g) => g.id == groupId)) {
        _userGroups.add(group);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    try {
      await _databaseService.leaveGroup(groupId, userId);

      // Update local state
      _userGroups.removeWhere((g) => g.id == groupId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createGroup(String name, String description, String category) async {
    try {
      final group = StudyGroup(
        name: name,
        description: description,
        category: category,
        createdBy: 'current_user', // Replace with actual user ID
        createdAt: DateTime.now(),
      );

      final groupId = await _databaseService.insertStudyGroup(group);

      // Add to local list
      _groups.add(group.copyWith(id: groupId));
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchGroups(String query) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _groups = await _databaseService.searchStudyGroups(query);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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