import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isDarkMode = false;

  int get currentIndex => _currentIndex;
  bool get isDarkMode => _isDarkMode;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}
