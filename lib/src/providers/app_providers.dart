import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  double _textSizeMultiplier = 1.0;
  bool _accessibilityMode = false;

  ThemeMode get themeMode => _themeMode;
  double get textSizeMultiplier => _textSizeMultiplier;
  bool get accessibilityMode => _accessibilityMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setTextSize(String size) {
    switch (size) {
      case 'small':
        _textSizeMultiplier = 0.85;
        break;
      case 'large':
        _textSizeMultiplier = 1.2;
        break;
      case 'xlarge':
        _textSizeMultiplier = 1.4;
        break;
      default:
        _textSizeMultiplier = 1.0;
        break;
    }
    notifyListeners();
  }

  void setAccessibilityMode(bool enabled) {
    _accessibilityMode = enabled;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isDrawerOpen = false;

  int get currentIndex => _currentIndex;
  bool get isDrawerOpen => _isDrawerOpen;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setDrawerState(bool isOpen) {
    _isDrawerOpen = isOpen;
    notifyListeners();
  }

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }
}

class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<AuthService>(create: (_) => AuthService()..initializeDemoMode()),
    ChangeNotifierProvider<DatabaseService>(create: (_) => DatabaseService()..initialize()),
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ChangeNotifierProvider<NavigationProvider>(create: (_) => NavigationProvider()),
  ];
}

