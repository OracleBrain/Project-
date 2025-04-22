import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teacher_attendance_app/models/teacher.dart';
import 'package:teacher_attendance_app/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  
  User? _user;
  Teacher? _teacherProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get user => _user;
  Teacher? get teacherProfile => _teacherProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadTeacherProfile();
      } else {
        _teacherProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadTeacherProfile() async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final teacherData = await _firebaseService.getTeacherProfile(_user!.uid);
      if (teacherData != null) {
        _teacherProfile = Teacher.fromMap(teacherData, _user!.uid);
      }
    } catch (e) {
      _errorMessage = 'Failed to load teacher profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          _errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is not valid.';
          break;
        default:
          _errorMessage = 'Authentication failed: ${e.message}';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Authentication failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String name, String department, String employeeId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create teacher profile
      final teacher = Teacher(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        department: department,
        employeeId: employeeId,
      );
      
      // Save to Firestore
      await _firebaseService.createTeacherProfile(teacher);
      
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'This email is already registered.';
          break;
        case 'weak-password':
          _errorMessage = 'The password is too weak.';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is not valid.';
          break;
        default:
          _errorMessage = 'Registration failed: ${e.message}';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _auth.signOut();
    } catch (e) {
      _errorMessage = 'Sign out failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Teacher updatedTeacher) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _firebaseService.updateTeacherProfile(updatedTeacher);
      _teacherProfile = updatedTeacher;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );
      
      await _user!.reauthenticateWithCredential(credential);
      await _user!.updatePassword(newPassword);
      
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _errorMessage = 'Current password is incorrect.';
          break;
        default:
          _errorMessage = 'Failed to update password: ${e.message}';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update password: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No user found with this email.';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is not valid.';
          break;
        default:
          _errorMessage = 'Password reset failed: ${e.message}';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Password reset failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}