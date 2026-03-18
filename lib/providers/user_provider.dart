import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream all users (for admin)
  void loadUsers() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.streamAllUsers().listen(
      (users) {
        _users = users;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Toggle notification permission
  Future<void> toggleNotificationPermission(String userId, bool value) async {
    try {
      await _firestoreService.toggleNotificationPermission(userId, value);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestoreService.updateUserRole(userId, role);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
