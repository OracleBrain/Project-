class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String recipientId;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.recipientId,
    required this.type,
    this.data = const {},
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime notificationTime;
    try {
      if (data['timestamp'] is Map && data['timestamp'].containsKey('seconds')) {
        notificationTime = DateTime.fromMillisecondsSinceEpoch(
            (data['timestamp']['seconds'] * 1000).toInt());
      } else {
        notificationTime = DateTime.now();
      }
    } catch (e) {
      notificationTime = DateTime.now();
    }

    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: notificationTime,
      recipientId: data['recipientId'] ?? '',
      type: data['type'] ?? 'general',
      data: data['data'] ?? {},
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'recipientId': recipientId,
      'type': type,
      'data': data,
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? body,
    DateTime? timestamp,
    String? recipientId,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return NotificationModel(
      id: this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }

  NotificationModel markAsRead() {
    return copyWith(isRead: true);
  }
}