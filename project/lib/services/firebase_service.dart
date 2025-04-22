import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teacher_attendance_app/models/attendance.dart';
import 'package:teacher_attendance_app/models/class_model.dart';
import 'package:teacher_attendance_app/models/notification_model.dart';
import 'package:teacher_attendance_app/models/student.dart';
import 'package:teacher_attendance_app/models/teacher.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Teacher Methods
  Future<Map<String, dynamic>?> getTeacherProfile(String teacherId) async {
    final docSnapshot = await _firestore.collection('teachers').doc(teacherId).get();
    return docSnapshot.exists ? docSnapshot.data() : null;
  }

  Future<void> createTeacherProfile(Teacher teacher) async {
    await _firestore.collection('teachers').doc(teacher.id).set(teacher.toMap());
  }

  Future<void> updateTeacherProfile(Teacher teacher) async {
    await _firestore.collection('teachers').doc(teacher.id).update(teacher.toMap());
  }

  // Class Methods
  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    final querySnapshot = await _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .get();
    
    return querySnapshot.docs
        .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> createClass(ClassModel classModel) async {
    final docRef = await _firestore.collection('classes').add(classModel.toMap());
    return docRef.id;
  }

  Future<void> updateClass(ClassModel classModel) async {
    await _firestore.collection('classes').doc(classModel.id).update(classModel.toMap());
  }

  // Student Methods
  Future<List<Student>> getClassStudents(String classId) async {
    final classDoc = await _firestore.collection('classes').doc(classId).get();
    final classData = classDoc.data();
    
    if (classData == null || !classData.containsKey('studentIds')) {
      return [];
    }
    
    final studentIds = List<String>.from(classData['studentIds']);
    if (studentIds.isEmpty) {
      return [];
    }
    
    // Fetch students in batches if there are many
    List<Student> students = [];
    
    // Process in batches of 10 for Firestore limitations
    for (int i = 0; i < studentIds.length; i += 10) {
      final end = (i + 10 < studentIds.length) ? i + 10 : studentIds.length;
      final batch = studentIds.sublist(i, end);
      
      final querySnapshot = await _firestore
          .collection('students')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      
      students.addAll(
        querySnapshot.docs.map((doc) => Student.fromMap(doc.data(), doc.id))
      );
    }
    
    return students;
  }

  Future<String> createStudent(Student student) async {
    final docRef = await _firestore.collection('students').add(student.toMap());
    return docRef.id;
  }

  Future<void> addStudentToClass(Student student, String classId) async {
    // Check if student exists, create if not
    String studentId = student.id;
    if (studentId.isEmpty) {
      studentId = await createStudent(student);
    } else {
      // Update existing student
      await _firestore.collection('students').doc(studentId).update(student.toMap());
    }
    
    // Add student ID to class
    await _firestore.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayUnion([studentId]),
    });
    
    // Add class ID to student
    await _firestore.collection('students').doc(studentId).update({
      'enrolledClassIds': FieldValue.arrayUnion([classId]),
    });
  }

  Future<void> removeStudentFromClass(String studentId, String classId) async {
    // Remove student ID from class
    await _firestore.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayRemove([studentId]),
    });
    
    // Remove class ID from student
    await _firestore.collection('students').doc(studentId).update({
      'enrolledClassIds': FieldValue.arrayRemove([classId]),
    });
  }

  // Attendance Methods
  Future<List<AttendanceRecord>> getClassAttendanceRecords(String classId) async {
    final querySnapshot = await _firestore
        .collection('attendance')
        .where('classId', isEqualTo: classId)
        .orderBy('date', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => AttendanceRecord.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> saveAttendanceRecord(AttendanceRecord record) async {
    final docRef = await _firestore.collection('attendance').add(record.toMap());
    return docRef.id;
  }

  Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    await _firestore.collection('attendance').doc(record.id).update(record.toMap());
  }

  // Notification Methods
  Future<List<NotificationModel>> getTeacherNotifications(String teacherId) async {
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: teacherId)
        .orderBy('timestamp', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllNotificationsAsRead(String teacherId) async {
    final batch = _firestore.batch();
    
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: teacherId)
        .where('isRead', isEqualTo: false)
        .get();
    
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _firestore.collection('notifications').add(notification.toMap());
  }
}