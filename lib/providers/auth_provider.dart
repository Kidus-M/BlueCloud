import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, authenticating }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _firebaseUser;
  UserModel? _userModel;
  String? _error;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  String? get error => _error;
  bool get isAdmin => _userModel?.isAdmin ?? false;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _userModel = null;
    } else {
      _firebaseUser = user;
      _userModel = await _firestoreService.getUser(user.uid);
      if (_userModel != null) {
        _status = AuthStatus.authenticated;
        // Initialize notifications
        await _notificationService.initialize(user.uid);
        if (_userModel!.canReceiveNotifications) {
          await _notificationService.subscribeToReports();
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }

  // Sign Up
  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _error = null;
      notifyListeners();

      final credential = await _authService.signUp(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userModel = UserModel(
          id: credential.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          role: role,
          canReceiveNotifications: false,
        );

        await _firestoreService.createUser(userModel);
        _userModel = userModel;
        _firebaseUser = credential.user;
        _status = AuthStatus.authenticated;

        // Initialize notifications
        await _notificationService.initialize(credential.user!.uid);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _error = null;
      notifyListeners();

      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _userModel = await _firestoreService.getUser(credential.user!.uid);
        _firebaseUser = credential.user;
        _status = AuthStatus.authenticated;

        // Initialize notifications
        await _notificationService.initialize(credential.user!.uid);
        if (_userModel?.canReceiveNotifications ?? false) {
          await _notificationService.subscribeToReports();
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _notificationService.unsubscribeFromReports();
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    _firebaseUser = null;
    _userModel = null;
    _error = null;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
