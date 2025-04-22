class Teacher {
  final String id;
  final String name;
  final String email;
  final String department;
  final String photoUrl;
  final String phone;
  final String employeeId;
  final List<String> classIds;
  final Map<String, dynamic> preferences;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    this.photoUrl = '',
    this.phone = '',
    required this.employeeId,
    this.classIds = const [],
    this.preferences = const {},
  });

  factory Teacher.fromMap(Map<String, dynamic> data, String id) {
    return Teacher(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      phone: data['phone'] ?? '',
      employeeId: data['employeeId'] ?? '',
      classIds: List<String>.from(data['classIds'] ?? []),
      preferences: data['preferences'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'photoUrl': photoUrl,
      'phone': phone,
      'employeeId': employeeId,
      'classIds': classIds,
      'preferences': preferences,
    };
  }

  Teacher copyWith({
    String? name,
    String? email,
    String? department,
    String? photoUrl,
    String? phone,
    String? employeeId,
    List<String>? classIds,
    Map<String, dynamic>? preferences,
  }) {
    return Teacher(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      employeeId: employeeId ?? this.employeeId,
      classIds: classIds ?? this.classIds,
      preferences: preferences ?? this.preferences,
    );
  }
}