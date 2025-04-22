import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:teacher_attendance_app/models/attendance.dart';
import 'package:teacher_attendance_app/models/class_model.dart';
import 'package:teacher_attendance_app/models/student.dart';
import 'package:teacher_attendance_app/providers/attendance_provider.dart';
import 'package:teacher_attendance_app/providers/auth_provider.dart';
import 'package:teacher_attendance_app/providers/class_provider.dart';
import 'package:teacher_attendance_app/utils/theme.dart';
import 'package:teacher_attendance_app/widgets/class_dropdown.dart';
import 'package:teacher_attendance_app/widgets/custom_text_field.dart';
import 'package:teacher_attendance_app/widgets/loading_overlay.dart';
import 'package:teacher_attendance_app/widgets/student_attendance_item.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  ClassModel? _selectedClass;
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _loadClasses();
  }
  
  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadClasses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    
    if (authProvider.teacherProfile != null && classProvider.classes.isEmpty) {
      await classProvider.loadTeacherClasses(authProvider.teacherProfile!.id);
    }
  }
  
  void _onClassSelected(ClassModel? classModel) {
    setState(() {
      _selectedClass = classModel;
    });
    
    if (classModel != null) {
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      classProvider.loadClassStudents(classModel.id);
      
      if (authProvider.teacherProfile != null) {
        attendanceProvider.initializeNewAttendance(
          classModel.id,
          classModel.name,
          authProvider.teacherProfile!.id,
          classModel.studentIds,
        );
      }
    }
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      attendanceProvider.updateAttendanceDate(_selectedDate);
    }
  }
  
  void _updateTopic(String topic) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider.updateAttendanceTopic(topic);
  }
  
  void _updateNotes(String notes) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider.updateAttendanceNotes(notes);
  }
  
  Future<void> _saveAttendance() async {
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    if (_topicController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a topic'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final success = await attendanceProvider.saveAttendance();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(attendanceProvider.errorMessage),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    
    final List<Student> students = classProvider.students;
    final Map<String, AttendanceStatus> tempAttendance = attendanceProvider.tempAttendance;
    
    return LoadingOverlay(
      isLoading: classProvider.isLoading || attendanceProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mark Attendance'),
          actions: [
            TextButton.icon(
              onPressed: _saveAttendance,
              icon: const Icon(Icons.save_outlined, color: Colors.white),
              label: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Class selection and date picker
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.scaffoldDarkColor.withOpacity(0.8)
                  : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Class Dropdown
                  ClassDropdown(
                    classes: classProvider.getActiveClasses(),
                    selectedClass: _selectedClass,
                    onChanged: _onClassSelected,
                  ),
                  const SizedBox(height: 16),
                  // Date and Topic Row
                  Row(
                    children: [
                      // Date Picker
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Topic Input
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
                          controller: _topicController,
                          labelText: 'Topic',
                          hintText: 'Enter class topic',
                          onChanged: _updateTopic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Notes Input
                  CustomTextField(
                    controller: _notesController,
                    labelText: 'Notes (Optional)',
                    hintText: 'Add any additional notes',
                    maxLines: 2,
                    onChanged: _updateNotes,
                  ),
                ],
              ),
            ),
            // Quick actions for bulk marking
            if (students.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryDarkColor
                    : AppTheme.primaryLightColor,
                child: Row(
                  children: [
                    const Text(
                      'Mark all as:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildQuickActionButton(
                      label: 'Present',
                      status: AttendanceStatus.present,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionButton(
                      label: 'Absent',
                      status: AttendanceStatus.absent,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionButton(
                      label: 'Late',
                      status: AttendanceStatus.late,
                      color: AppTheme.warningColor,
                    ),
                  ],
                ),
              ),
            // Student List
            Expanded(
              child: _selectedClass == null
                  ? const Center(
                      child: Text('Please select a class to mark attendance'),
                    )
                  : students.isEmpty
                      ? const Center(
                          child: Text('No students in this class'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: students.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return StudentAttendanceItem(
                              student: student,
                              status: tempAttendance[student.id] ?? AttendanceStatus.absent,
                              onStatusChanged: (status) {
                                attendanceProvider.updateStudentAttendance(student.id, status);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required String label,
    required AttendanceStatus status,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () {
        final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
        final classProvider = Provider.of<ClassProvider>(context, listen: false);
        
        for (final student in classProvider.students) {
          attendanceProvider.updateStudentAttendance(student.id, status);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }
}