import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_attendance_app/models/student.dart';
import 'package:teacher_attendance_app/providers/attendance_provider.dart';
import 'package:teacher_attendance_app/providers/class_provider.dart';
import 'package:teacher_attendance_app/utils/theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StudentsListScreen extends StatelessWidget {
  final String classId;
  
  const StudentsListScreen({super.key, required this.classId});
  
  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final List<Student> students = classProvider.students;
    
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No students found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Students enrolled in this class will appear here',
              style: TextStyle(
                color: AppTheme.textGrayColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement add student functionality
              },
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Student'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[50],
            ),
            onChanged: (value) {
              // TODO: Implement search functionality
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final attendancePercentage = attendanceProvider.getStudentAttendancePercentage(
                student.id,
                classId,
              );
              
              return Slidable(
                key: ValueKey(student.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        // TODO: Implement view student details
                      },
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      icon: Icons.info_outline,
                      label: 'Details',
                    ),
                    SlidableAction(
                      onPressed: (_) {
                        // TODO: Implement remove student functionality
                      },
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline,
                      label: 'Remove',
                    ),
                  ],
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: student.photoUrl.isNotEmpty
                              ? null
                              : Text(
                                  student.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Roll No: ${student.rollNumber}',
                                style: const TextStyle(
                                  color: AppTheme.textGrayColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Semester: ${student.semester}',
                                style: const TextStyle(
                                  color: AppTheme.textGrayColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getAttendanceColor(attendancePercentage).withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              '${attendancePercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: _getAttendanceColor(attendancePercentage),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) {
      return AppTheme.successColor;
    } else if (percentage >= 50) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }
}