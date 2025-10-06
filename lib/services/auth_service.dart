import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
    String? firstName,
    String? lastName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseService.database;

      final existingUser = await db.query(
        'users',
        where: 'email = ? OR username = ?',
        whereArgs: [email, username],
      );

      if (existingUser.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = User.create(
        email: email,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );

      await db.insert('users', {
        ...user.toJson(),
        'password': _hashPassword(password),
      });

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseService.database;

      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, _hashPassword(password)],
      );

      if (result.isNotEmpty) {
        _currentUser = User.fromJson(result.first);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      // Update user in database
      await DatabaseHelper.instance.updateUser(updatedUser);

      // Update the current user in memory
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

}
