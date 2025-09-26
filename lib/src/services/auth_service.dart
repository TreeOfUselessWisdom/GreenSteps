import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Mock authentication for demo purposes
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo user authentication
      if (email == 'account4youGreensteps@gmail.com.com' && password == '123456') {
        _currentUser = UserModel(
          uid: 'user_123',
          displayName: 'User',
          email: email,
          photoUrl: 'https://ui-avatars.com/api/?name=Demo+User&size=200&background=2E7D32&color=fff',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          preferences: const UserPreferences(),
        );
        _setLoading(false);
        return true;
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Demo user creation (in real app, would create in Firebase)
      // Note: Not auto-logging in as per requirements
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate Google sign-in delay
      await Future.delayed(const Duration(seconds: 2));

      // Demo Google user
      _currentUser = UserModel(
        uid: 'google_user_456',
        displayName: 'Sarah Green',
        email: 'sarah.green@gmail.com',
        photoUrl: 'https://ui-avatars.com/api/?name=Sarah+Green&size=200&background=4CAF50&color=fff',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        preferences: const UserPreferences(),
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    UserPreferences? preferences,
  }) async {
    if (_currentUser == null) return false;

    try {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        preferences: preferences ?? _currentUser!.preferences,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize with demo user for immediate app functionality
  void initializeDemoMode() {
    _currentUser = UserModel(
      uid: 'user_123',
      displayName: 'User',
      email: 'account4youGreensteps@gmail.com',
      photoUrl: 'https://ui-avatars.com/api/?name=Demo+User&size=200&background=2E7D32&color=fff',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      preferences: const UserPreferences(),
    );
    notifyListeners();
  }
}
