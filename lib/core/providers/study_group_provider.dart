import 'package:flutter/foundation.dart';
import '../../services/database_service.dart';
import '../models/study_group_model.dart';

class StudyGroupProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<StudyGroup> _groups = [];
  List<StudyGroup> _userGroups = [];
  bool _isLoading = false;

  List<StudyGroup> get groups => _groups;
  List<StudyGroup> get userGroups => _userGroups;
  bool get isLoading => _isLoading;

  Future<void> loadGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _databaseService.getStudyGroups();
      notifyListeners();
    } catch (e) {
      print('Error loading groups: $e');
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
      notifyListeners();
    } catch (e) {
      print('Error loading user groups: $e');
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
      print('Error joining group: $e');
    }
  }

  Future<void> leaveGroup(int groupId, String userId) async {
    try {
      await _databaseService.leaveGroup(groupId, userId);

      _userGroups.removeWhere((g) => g.id == groupId);
      notifyListeners();
    } catch (e) {
      print('Error leaving group: $e');
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required String category,
    required String createdBy,
    bool isPublic = true,
  }) async {
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
      final newGroup = group.copyWith(id: groupId);
      _groups.insert(0, newGroup);

      // Auto-join the creator
      await joinGroup(groupId, createdBy);

      notifyListeners();
    } catch (e) {
      print('Error creating group: $e');
    }
  }

  Future<void> searchGroups(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _groups = await _databaseService.searchStudyGroups(query);
      notifyListeners();
    } catch (e) {
      print('Error searching groups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isUserInGroup(int groupId, String userId) async {
    try {
      return await _databaseService.isUserInGroup(groupId, userId);
    } catch (e) {
      print('Error checking group membership: $e');
      return false;
    }
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
    notifyListeners();
  }
}