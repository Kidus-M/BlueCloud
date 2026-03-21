import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

class ReportProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ReportModel> _reports = [];
  List<ReportModel> _myReports = [];
  final Set<String> _readReportIds = {};
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String? _successMessage;

  List<ReportModel> get reports => _reports;
  List<ReportModel> get myReports => _myReports;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get successMessage => _successMessage;

  /// Number of unread reports
  int getUnreadCount(String userId) {
    if (userId.isEmpty) return 0;
    return _reports.where((r) => r.createdBy != userId && !_readReportIds.contains(r.id)).length;
  }

  /// Check if a specific report is unread
  bool isUnread(ReportModel report, String userId) {
    if (userId.isEmpty) return false;
    if (report.createdBy == userId) return false;
    return !_readReportIds.contains(report.id);
  }

  /// Mark a report as read
  void markAsRead(String? reportId, String userId) {
    if (reportId == null) return;
    if (_readReportIds.add(reportId)) {
      // Save to Firestore for persistence
      _firestoreService.markReportRead(userId, reportId);
      notifyListeners();
    }
  }

  /// Load the user's read report IDs from Firestore
  Future<void> loadReadReports(String userId) async {
    try {
      final readIds = await _firestoreService.getReadReportIds(userId);
      _readReportIds.clear();
      _readReportIds.addAll(readIds);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load read reports: $e');
    }
  }

  // Stream all reports
  void loadReports() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.streamReports().listen(
      (reports) {
        _reports = reports;
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

  // Stream user's reports
  void loadMyReports(String userId) {
    _firestoreService.streamReportsByUser(userId).listen(
      (reports) {
        _myReports = reports;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // Submit a report
  Future<bool> submitReport(ReportModel report) async {
    try {
      _isSubmitting = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _firestoreService.createReport(report);

      _isSubmitting = false;
      _successMessage = 'Report submitted successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
