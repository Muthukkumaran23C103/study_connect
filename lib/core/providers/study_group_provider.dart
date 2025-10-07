import 'package:flutter/foundation.dart';
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

      // Update the local lists
      final group = _groups.firstWhere((g) => g.id == groupId);
      if (!_userGroups.any((g) => g.id == groupId)) {
        _userGroups.add(group);
      }

      // Update member count
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        _groups[groupIndex] = group.copyWith(memberCount: group.memberCount + 1);
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    try {
      await _databaseService.leaveGroup(groupId, userId);

      // Update the local lists
      _userGroups.removeWhere((g) => g.id == groupId);

      // Update member count
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final group = _groups[groupIndex];
        _groups[groupIndex] = group.copyWith(
          memberCount: group.memberCount > 0 ? group.memberCount - 1 : 0,
        );
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required String category,
    required int createdBy,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final group = StudyGroup(
        name: name,
        description: description,
        category: category,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );

      final groupId = await _databaseService.insertStudyGroup(group);

      // Add the new group to the local list
      final newGroup = group.copyWith(id: groupId);
      _groups.add(newGroup);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
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

  void clearGroups() {
    _groups.clear();
    _userGroups.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}