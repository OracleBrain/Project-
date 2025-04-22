import 'package:flutter/material.dart';
import 'package:teacher_attendance_app/models/notification_model.dart';
import 'package:teacher_attendance_app/services/firebase_service.dart';
import 'package:teacher_attendance_app/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get unreadCount => unreadNotifications.length;

  Future<void> loadTeacherNotifications(String teacherId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final notificationData = await _firebaseService.getTeacherNotifications(teacherId);
      _notifications = notificationData;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _firebaseService.markNotificationAsRead(notificationId);
      
      // Update local list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark notification as read: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAllAsRead(String teacherId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _firebaseService.markAllNotificationsAsRead(teacherId);
      
      // Update local list
      _notifications = _notifications.map((n) => n.markAsRead()).toList();
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark all notifications as read: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _firebaseService.deleteNotification(notificationId);
      
      // Update local list
      _notifications.removeWhere((n) => n.id == notificationId);
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete notification: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> showLocalNotification(String title, String body, {Map<String, dynamic>? payload}) async {
    await _notificationService.showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }

  List<NotificationModel> getRecentNotifications() {
    final sorted = List<NotificationModel>.from(_notifications)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return sorted.take(5).toList();
  }
}