import 'package:flutter/material.dart';
import 'package:teacher_attendance_app/models/attendance.dart';
import 'package:teacher_attendance_app/services/firebase_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<AttendanceRecord> _attendanceRecords = [];
  AttendanceRecord? _currentRecord;
  Map<String, AttendanceStatus> _tempAttendance = {};
  bool _isLoading = false;
  String _errorMessage = '';

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceRecord? get currentRecord => _currentRecord;
  Map<String, AttendanceStatus> get tempAttendance => _tempAttendance;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadClassAttendance(String classId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final records = await _firebaseService.getClassAttendanceRecords(classId);
      _attendanceRecords = records;
    } catch (e) {
      _errorMessage = 'Failed to load attendance records: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void initializeNewAttendance(String classId, String className, String teacherId, List<String> studentIds) {
    _tempAttendance = {};
    
    // Initialize with all students marked as absent
    for (final studentId in studentIds) {
      _tempAttendance[studentId] = AttendanceStatus.absent;
    }
    
    _currentRecord = AttendanceRecord(
      id: '', // Will be assigned when saved
      classId: classId,
      className: className,
      teacherId: teacherId,
      date: DateTime.now(),
      topic: '',
      studentAttendance: Map.from(_tempAttendance),
    );
    
    notifyListeners();
  }

  void updateStudentAttendance(String studentId, AttendanceStatus status) {
    _tempAttendance[studentId] = status;
    notifyListeners();
  }

  void updateAttendanceTopic(String topic) {
    if (_currentRecord != null) {
      _currentRecord = _currentRecord!.copyWith(topic: topic);
    }
    notifyListeners();
  }

  void updateAttendanceNotes(String notes) {
    if (_currentRecord != null) {
      _currentRecord = _currentRecord!.copyWith(notes: notes);
    }
    notifyListeners();
  }

  void updateAttendanceDate(DateTime date) {
    if (_currentRecord != null) {
      _currentRecord = _currentRecord!.copyWith(date: date);
    }
    notifyListeners();
  }

  Future<bool> saveAttendance() async {
    if (_currentRecord == null) return false;
    
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Create a new record with the current temp attendance
      final recordToSave = _currentRecord!.copyWith(
        studentAttendance: Map.from(_tempAttendance),
      );
      
      final recordId = await _firebaseService.saveAttendanceRecord(recordToSave);
      
      // Update local record with assigned ID
      final savedRecord = recordToSave.copyWith(id: recordId);
      _attendanceRecords.add(savedRecord);
      _currentRecord = null;
      _tempAttendance = {};
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save attendance: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAttendanceRecord(AttendanceRecord updatedRecord) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _firebaseService.updateAttendanceRecord(updatedRecord);
      
      // Update local list
      final index = _attendanceRecords.indexWhere((r) => r.id == updatedRecord.id);
      if (index != -1) {
        _attendanceRecords[index] = updatedRecord;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update attendance record: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double getStudentAttendancePercentage(String studentId, String classId) {
    final classRecords = _attendanceRecords.where((r) => r.classId == classId).toList();
    if (classRecords.isEmpty) return 0.0;
    
    int present = 0;
    int total = 0;
    
    for (final record in classRecords) {
      if (record.studentAttendance.containsKey(studentId)) {
        total++;
        final status = record.studentAttendance[studentId];
        if (status == AttendanceStatus.present || status == AttendanceStatus.late) {
          present++;
        }
      }
    }
    
    return total > 0 ? (present / total * 100) : 0.0;
  }

  List<AttendanceRecord> getRecentAttendance() {
    final sorted = List<AttendanceRecord>.from(_attendanceRecords)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return sorted.take(10).toList();
  }

  Map<String, int> getMonthlyAttendanceSummary(String classId) {
    final classRecords = _attendanceRecords.where((r) => r.classId == classId).toList();
    Map<String, int> monthlySummary = {};
    
    for (final record in classRecords) {
      final month = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      final presentCount = record.presentCount + record.lateCount;
      
      if (monthlySummary.containsKey(month)) {
        monthlySummary[month] = (monthlySummary[month] ?? 0) + presentCount;
      } else {
        monthlySummary[month] = presentCount;
      }
    }
    
    return monthlySummary;
  }
}