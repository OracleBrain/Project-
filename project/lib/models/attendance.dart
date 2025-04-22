import 'package:intl/intl.dart';

class AttendanceRecord {
  final String id;
  final String classId;
  final String className;
  final String teacherId;
  final DateTime date;
  final String topic;
  final Map<String, AttendanceStatus> studentAttendance;
  final String notes;

  AttendanceRecord({
    required this.id,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.date,
    required this.topic,
    required this.studentAttendance,
    this.notes = '',
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> data, String id) {
    // Convert Firebase timestamp to DateTime
    DateTime recordDate;
    try {
      if (data['date'] is Map && data['date'].containsKey('seconds')) {
        recordDate = DateTime.fromMillisecondsSinceEpoch(
            (data['date']['seconds'] * 1000).toInt());
      } else {
        recordDate = DateTime.now();
      }
    } catch (e) {
      recordDate = DateTime.now();
    }

    // Convert student attendance data
    Map<String, AttendanceStatus> attendance = {};
    if (data['studentAttendance'] != null) {
      data['studentAttendance'].forEach((studentId, status) {
        attendance[studentId] = _parseAttendanceStatus(status);
      });
    }

    return AttendanceRecord(
      id: id,
      classId: data['classId'] ?? '',
      className: data['className'] ?? '',
      teacherId: data['teacherId'] ?? '',
      date: recordDate,
      topic: data['topic'] ?? '',
      studentAttendance: attendance,
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    // Convert attendance status to string for storage
    Map<String, String> attendanceData = {};
    studentAttendance.forEach((studentId, status) {
      attendanceData[studentId] = status.toString().split('.').last;
    });

    return {
      'classId': classId,
      'className': className,
      'teacherId': teacherId,
      'date': date,
      'topic': topic,
      'studentAttendance': attendanceData,
      'notes': notes,
    };
  }

  static AttendanceStatus _parseAttendanceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.absent;
    }
  }

  String get formattedDate => DateFormat('EEEE, MMMM d, yyyy').format(date);
  String get shortDate => DateFormat('MMM d, yyyy').format(date);

  int get presentCount => studentAttendance.values
      .where((status) => status == AttendanceStatus.present)
      .length;

  int get absentCount => studentAttendance.values
      .where((status) => status == AttendanceStatus.absent)
      .length;

  int get lateCount => studentAttendance.values
      .where((status) => status == AttendanceStatus.late)
      .length;

  int get excusedCount => studentAttendance.values
      .where((status) => status == AttendanceStatus.excused)
      .length;

  double get attendancePercentage {
    if (studentAttendance.isEmpty) return 0.0;
    return (presentCount + lateCount) / studentAttendance.length * 100;
  }

  AttendanceRecord copyWith({
    String? classId,
    String? className,
    String? teacherId,
    DateTime? date,
    String? topic,
    Map<String, AttendanceStatus>? studentAttendance,
    String? notes,
  }) {
    return AttendanceRecord(
      id: this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      teacherId: teacherId ?? this.teacherId,
      date: date ?? this.date,
      topic: topic ?? this.topic,
      studentAttendance: studentAttendance ?? this.studentAttendance,
      notes: notes ?? this.notes,
    );
  }
}

enum AttendanceStatus { present, absent, late, excused }