import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Email/password authentication via Firebase Auth
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Sign-in failed');

      _currentUser = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? 'User',
        email: user.email ?? email,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
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

  Future<bool> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
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
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in aborted');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _firebaseAuth.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) throw Exception('Google sign-in failed');

      _currentUser = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? 'User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
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
    try {
      await _firebaseAuth.signOut();
    } finally {
      _currentUser = null;
      notifyListeners();
    }
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

  // Optional: no-op demo initializer when using Firebase
  void initializeDemoMode() {}
}
