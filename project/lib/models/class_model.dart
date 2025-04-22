class ClassModel {
  final String id;
  final String name;
  final String courseCode;
  final String department;
  final String schedule;
  final String room;
  final String teacherId;
  final int semester;
  final List<String> studentIds;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  ClassModel({
    required this.id,
    required this.name,
    required this.courseCode,
    required this.department,
    required this.schedule,
    required this.room,
    required this.teacherId,
    required this.semester,
    this.studentIds = const [],
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory ClassModel.fromMap(Map<String, dynamic> data, String id) {
    return ClassModel(
      id: id,
      name: data['name'] ?? '',
      courseCode: data['courseCode'] ?? '',
      department: data['department'] ?? '',
      schedule: data['schedule'] ?? '',
      room: data['room'] ?? '',
      teacherId: data['teacherId'] ?? '',
      semester: data['semester'] ?? 1,
      studentIds: List<String>.from(data['studentIds'] ?? []),
      startDate: (data['startDate'] as Map<String, dynamic>?)?.containsKey('seconds') 
          ? DateTime.fromMillisecondsSinceEpoch((data['startDate']['seconds'] * 1000).toInt())
          : DateTime.now(),
      endDate: (data['endDate'] as Map<String, dynamic>?)?.containsKey('seconds')
          ? DateTime.fromMillisecondsSinceEpoch((data['endDate']['seconds'] * 1000).toInt())
          : DateTime.now().add(const Duration(days: 120)),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'courseCode': courseCode,
      'department': department,
      'schedule': schedule,
      'room': room,
      'teacherId': teacherId,
      'semester': semester,
      'studentIds': studentIds,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
    };
  }

  ClassModel copyWith({
    String? name,
    String? courseCode,
    String? department,
    String? schedule,
    String? room,
    String? teacherId,
    int? semester,
    List<String>? studentIds,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return ClassModel(
      id: this.id,
      name: name ?? this.name,
      courseCode: courseCode ?? this.courseCode,
      department: department ?? this.department,
      schedule: schedule ?? this.schedule,
      room: room ?? this.room,
      teacherId: teacherId ?? this.teacherId,
      semester: semester ?? this.semester,
      studentIds: studentIds ?? this.studentIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}