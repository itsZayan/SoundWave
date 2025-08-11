import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundwave_flutter_app/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true; // Default to dark
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme');
      if (savedTheme != null) {
        _isDarkMode = savedTheme == 'dark';
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error loading theme: $error');
    }
  }
  
  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', _isDarkMode ? 'dark' : 'light');
      notifyListeners();
    } catch (error) {
      debugPrint('Error saving theme: $error');
    }
  }
}
