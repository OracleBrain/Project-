import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:teacher_attendance_app/models/notification_model.dart';
import 'package:teacher_attendance_app/providers/auth_provider.dart';
import 'package:teacher_attendance_app/providers/notification_provider.dart';
import 'package:teacher_attendance_app/utils/theme.dart';
import 'package:teacher_attendance_app/widgets/loading_overlay.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    if (authProvider.teacherProfile != null) {
      await notificationProvider.loadTeacherNotifications(authProvider.teacherProfile!.id);
    }
  }
  
  Future<void> _markAllAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    if (authProvider.teacherProfile != null) {
      await notificationProvider.markAllAsRead(authProvider.teacherProfile!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;
    
    return LoadingOverlay(
      isLoading: notificationProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            if (notificationProvider.unreadCount > 0)
              TextButton.icon(
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all, color: Colors.white),
                label: const Text(
                  'Mark all as read',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You\'re all caught up!',
                      style: TextStyle(
                        color: AppTheme.textGrayColor,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationItem(notification);
                },
              ),
      ),
    );
  }
  
  Widget _buildNotificationItem(NotificationModel notification) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final formattedTime = _formatNotificationTime(notification.timestamp);
    
    return Slidable(
      key: ValueKey(notification.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              await notificationProvider.markAsRead(notification.id);
            },
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            icon: Icons.done,
            label: 'Mark Read',
          ),
          SlidableAction(
            onPressed: (_) async {
              await notificationProvider.deleteNotification(notification.id);
            },
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: notification.isRead
            ? null
            : Theme.of(context).brightness == Brightness.dark
                ? AppTheme.primaryDarkColor.withOpacity(0.2)
                : AppTheme.primaryLightColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            color: AppTheme.textGrayColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: notification.isRead
                            ? AppTheme.textGrayColor
                            : null,
                        fontSize: 14,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          await notificationProvider.markAsRead(notification.id);
                        },
                        child: Text(
                          'Mark as read',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatNotificationTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'attendance':
        return AppTheme.primaryColor;
      case 'class':
        return AppTheme.secondaryColor;
      case 'student':
        return AppTheme.accentColor;
      case 'alert':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'attendance':
        return Icons.how_to_reg;
      case 'class':
        return Icons.class_outlined;
      case 'student':
        return Icons.people_outline;
      case 'alert':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}