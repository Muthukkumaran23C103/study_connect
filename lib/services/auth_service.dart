import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../utils/validators.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Hash password for security
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    String? college,
    String? year,
    String? branch,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validate input
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        _setError(emailError);
        return false;
      }

      final passwordError = Validators.validatePassword(password);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      final nameError = Validators.validateName(displayName);
      if (nameError != null) {
        _setError(nameError);
        return false;
      }

      // Check if user already exists
      final existingUser = await _databaseService.getUserByEmail(email);
      if (existingUser != null) {
        _setError('An account with this email already exists');
        return false;
      }

      // Create new user
      final hashedPassword = _hashPassword(password);
      final newUser = UserModel(
        email: email.toLowerCase().trim(),
        passwordHash: hashedPassword,
        displayName: displayName.trim(),
        college: college?.trim(),
        year: year,
        branch: branch?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Insert user to database
      final userId = await _databaseService.insertUser(newUser);
      if (userId > 0) {
        // Get the created user with ID
        _currentUser = newUser.copyWith(id: userId);
        // Save to shared preferences
        await _saveUserSession();
        return true;
      } else {
        _setError('Failed to create account. Please try again.');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validate input
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        _setError(emailError);
        return false;
      }

      if (password.isEmpty) {
        _setError('Password is required');
        return false;
      }

      // Get user from database
      final user = await _databaseService.getUserByEmail(email.toLowerCase().trim());
      if (user == null) {
        _setError('No account found with this email');
        return false;
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        _setError('Invalid password');
        return false;
      }

      // Update last active
      _currentUser = user.copyWith(updatedAt: DateTime.now());
      await _databaseService.updateUser(_currentUser!);

      // Save to shared preferences
      await _saveUserSession();
      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      _setLoading(true);
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      // Clear current user
      _currentUser = null;
      _setError(null);
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Save user session to SharedPreferences
  Future<void> _saveUserSession() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_user_id', _currentUser!.id!);
    }
  }

  // Load user session from SharedPreferences
  Future<void> loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');

      if (userId != null) {
        // Get user by ID from database (you'll need to implement this method)
        final users = await _databaseService.database;
        final result = await users.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
          limit: 1,
        );

        if (result.isNotEmpty) {
          _currentUser = UserModel.fromMap(result.first);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading user session: $e');
      // Clear invalid session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? college,
    String? year,
    String? branch,
    String? avatarPath,
  }) async {
    try {
      if (_currentUser == null) {
        _setError('No user logged in');
        return false;
      }

      _setLoading(true);
      _setError(null);

      // Validate display name if provided
      if (displayName != null) {
        final nameError = Validators.validateName(displayName);
        if (nameError != null) {
          _setError(nameError);
          return false;
        }
      }

      // Update user
      final updatedUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        college: college ?? _currentUser!.college,
        year: year ?? _currentUser!.year,
        branch: branch ?? _currentUser!.branch,
        avatarPath: avatarPath ?? _currentUser!.avatarPath,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateUser(updatedUser);
      _currentUser = updatedUser;
      return true;
    } catch (e) {
      _setError('Update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) {
        _setError('No user logged in');
        return false;
      }

      _setLoading(true);
      _setError(null);

      // Validate new password
      final passwordError = Validators.validatePassword(newPassword);
      if (passwordError != null) {
        _setError(passwordError);
        return false;
      }

      // Verify current password
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (_currentUser!.passwordHash != hashedCurrentPassword) {
        _setError('Current password is incorrect');
        return false;
      }

      // Update password
      final hashedNewPassword = _hashPassword(newPassword);
      final updatedUser = _currentUser!.copyWith(
        passwordHash: hashedNewPassword,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateUser(updatedUser);
      _currentUser = updatedUser;
      return true;
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}