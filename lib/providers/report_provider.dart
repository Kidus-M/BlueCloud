import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

class ReportProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ReportModel> _reports = [];
  List<ReportModel> _myReports = [];
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
