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

  /// Safely initialize notifications — never throws
  Future<void> _initNotificationsSafely(String userId, {bool canReceive = false}) async {
    try {
      await _notificationService.initialize(userId);
      if (canReceive) {
        await _notificationService.subscribeToReports();
      }
    } catch (e) {
      debugPrint('Notification init failed (non-fatal): $e');
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _userModel = null;
    } else {
      _firebaseUser = user;
      try {
        _userModel = await _firestoreService.getUser(user.uid);
      } catch (e) {
        debugPrint('Failed to load user model: $e');
        _userModel = null;
      }

      if (_userModel != null) {
        _status = AuthStatus.authenticated;
        // Initialize notifications in the background — don't block auth
        _initNotificationsSafely(
          user.uid,
          canReceive: _userModel!.canReceiveNotifications,
        );
      } else {
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }

  // Emails that are automatically given admin role
  static const List<String> _adminEmails = [
    'tekula.habesha@gmail.com',
    'kidusmesfinteferi@gmail.com',
  ];

  static bool _isAdminEmail(String email) {
    return _adminEmails.contains(email.toLowerCase().trim());
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

      // Auto-assign admin role for whitelisted emails
      final assignedRole = _isAdminEmail(email) ? 'admin' : role;
      
      // Auto-grant permissions to SF Gov emails
      final bool isSfGov = email.trim().toLowerCase().endsWith('@sfgov.org');
      final bool canReceive = assignedRole == 'admin' || isSfGov;

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
          role: assignedRole,
          canReceiveNotifications: canReceive,
        );

        await _firestoreService.createUser(userModel);
        _userModel = userModel;
        _firebaseUser = credential.user;
        _status = AuthStatus.authenticated;
        notifyListeners();

        // Initialize notifications AFTER marking auth as successful
        _initNotificationsSafely(credential.user!.uid);

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
        notifyListeners();

        // Initialize notifications AFTER marking auth as successful
        _initNotificationsSafely(
          credential.user!.uid,
          canReceive: _userModel?.canReceiveNotifications ?? false,
        );

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
    try {
      await _notificationService.unsubscribeFromReports();
    } catch (e) {
      debugPrint('Failed to unsubscribe from reports: $e');
    }
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
      try {
        _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
      } catch (e) {
        debugPrint('Failed to refresh user: $e');
      }
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
