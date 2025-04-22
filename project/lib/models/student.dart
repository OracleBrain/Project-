class Student {
  final String id;
  final String name;
  final String rollNumber;
  final String photoUrl;
  final String department;
  final int semester;
  final String email;
  final String phone;
  final List<String> enrolledClassIds;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    this.photoUrl = '',
    required this.department,
    required this.semester,
    this.email = '',
    this.phone = '',
    this.enrolledClassIds = const [],
  });

  factory Student.fromMap(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      department: data['department'] ?? '',
      semester: data['semester'] ?? 1,
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      enrolledClassIds: List<String>.from(data['enrolledClassIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rollNumber': rollNumber,
      'photoUrl': photoUrl,
      'department': department,
      'semester': semester,
      'email': email,
      'phone': phone,
      'enrolledClassIds': enrolledClassIds,
    };
  }

  Student copyWith({
    String? name,
    String? rollNumber,
    String? photoUrl,
    String? department,
    int? semester,
    String? email,
    String? phone,
    List<String>? enrolledClassIds,
  }) {
    return Student(
      id: this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      enrolledClassIds: enrolledClassIds ?? this.enrolledClassIds,
    );
  }
}