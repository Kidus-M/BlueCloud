import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  // Create user document in Firestore
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Get all users (for admin)
  Stream<List<UserModel>> streamAllUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Toggle notification permission (admin only)
  Future<void> toggleNotificationPermission(String userId, bool value) async {
    await _db.collection('users').doc(userId).update({
      'canReceiveNotifications': value,
    });
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String userId, String role) async {
    await _db.collection('users').doc(userId).update({
      'role': role,
    });
  }

  // Get users with notification permission
  Future<List<UserModel>> getUsersWithNotificationPermission() async {
    final snapshot = await _db
        .collection('users')
        .where('canReceiveNotifications', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ==================== REPORT OPERATIONS ====================

  // Create a report
  Future<DocumentReference> createReport(ReportModel report) async {
    return await _db.collection('reports').add(report.toMap());
  }

  // Get all reports (stream)
  Stream<List<ReportModel>> streamReports() {
    return _db
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get reports by user
  Stream<List<ReportModel>> streamReportsByUser(String userId) {
    return _db
        .collection('reports')
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single report
  Future<ReportModel?> getReport(String reportId) async {
    final doc = await _db.collection('reports').doc(reportId).get();
    if (doc.exists) {
      return ReportModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Store FCM token
  Future<void> updateFcmToken(String userId, String token) async {
    await _db.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  // Get FCM tokens of notification-enabled users
  Future<List<String>> getNotificationTokens() async {
    final snapshot = await _db
        .collection('users')
        .where('canReceiveNotifications', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['fcmToken'] as String?)
        .where((token) => token != null && token.isNotEmpty)
        .cast<String>()
        .toList();
  }
}
