import 'package:flutter/material.dart';
import 'package:teacher_attendance_app/models/class_model.dart';
import 'package:teacher_attendance_app/models/student.dart';
import 'package:teacher_attendance_app/services/firebase_service.dart';

class ClassProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<ClassModel> _classes = [];
  List<Student> _students = [];
  bool _isLoading = false;
  String _errorMessage = '';
  ClassModel? _selectedClass;

  List<ClassModel> get classes => _classes;
  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ClassModel? get selectedClass => _selectedClass;

  Future<void> loadTeacherClasses(String teacherId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final classesData = await _firebaseService.getTeacherClasses(teacherId);
      _classes = classesData;
    } catch (e) {
      _errorMessage = 'Failed to load classes: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClassStudents(String classId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final studentsData = await _firebaseService.getClassStudents(classId);
      _students = studentsData;
    } catch (e) {
      _errorMessage = 'Failed to load students: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectClass(ClassModel selectedClass) {
    _selectedClass = selectedClass;
    loadClassStudents(selectedClass.id);
    notifyListeners();
  }

  Future<bool> addClass(ClassModel newClass) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final classId = await _firebaseService.createClass(newClass);
      final createdClass = newClass.copyWith(id: classId);
      _classes.add(createdClass);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add class: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClass(ClassModel updatedClass) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _firebaseService.updateClass(updatedClass);
      
      // Update local list
      final index = _classes.indexWhere((c) => c.id == updatedClass.id);
      if (index != -1) {
        _classes[index] = updatedClass;
      }
      
      if (_selectedClass?.id == updatedClass.id) {
        _selectedClass = updatedClass;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update class: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStudentToClass(Student student, String classId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _firebaseService.addStudentToClass(student, classId);
      
      // Update local lists
      if (!_students.any((s) => s.id == student.id)) {
        _students.add(student);
      }
      
      final classIndex = _classes.indexWhere((c) => c.id == classId);
      if (classIndex != -1) {
        final updatedStudentIds = List<String>.from(_classes[classIndex].studentIds);
        if (!updatedStudentIds.contains(student.id)) {
          updatedStudentIds.add(student.id);
          _classes[classIndex] = _classes[classIndex].copyWith(studentIds: updatedStudentIds);
        }
        
        if (_selectedClass?.id == classId) {
          _selectedClass = _classes[classIndex];
        }
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add student to class: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeStudentFromClass(String studentId, String classId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _firebaseService.removeStudentFromClass(studentId, classId);
      
      // Update local lists
      final classIndex = _classes.indexWhere((c) => c.id == classId);
      if (classIndex != -1) {
        final updatedStudentIds = List<String>.from(_classes[classIndex].studentIds)
          ..removeWhere((id) => id == studentId);
        
        _classes[classIndex] = _classes[classIndex].copyWith(studentIds: updatedStudentIds);
        
        if (_selectedClass?.id == classId) {
          _selectedClass = _classes[classIndex];
        }
      }
      
      _students.removeWhere((s) => s.id == studentId);
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove student from class: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ClassModel> getActiveClasses() {
    return _classes.where((c) => c.isActive).toList();
  }

  ClassModel? getClassById(String classId) {
    try {
      return _classes.firstWhere((c) => c.id == classId);
    } catch (e) {
      return null;
    }
  }

  Student? getStudentById(String studentId) {
    try {
      return _students.firstWhere((s) => s.id == studentId);
    } catch (e) {
      return null;
    }
  }
}