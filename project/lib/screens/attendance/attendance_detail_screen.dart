import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_attendance_app/models/attendance.dart';
import 'package:teacher_attendance_app/models/student.dart';
import 'package:teacher_attendance_app/providers/attendance_provider.dart';
import 'package:teacher_attendance_app/providers/class_provider.dart';
import 'package:teacher_attendance_app/utils/theme.dart';
import 'package:teacher_attendance_app/widgets/attendance_status_chip.dart';
import 'package:teacher_attendance_app/widgets/loading_overlay.dart';

class AttendanceDetailScreen extends StatefulWidget {
  final AttendanceRecord record;
  
  const AttendanceDetailScreen({super.key, required this.record});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  Map<String, AttendanceStatus> _editedAttendance = {};
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _editedAttendance = Map<String, AttendanceStatus>.from(widget.record.studentAttendance);
    _loadStudents();
  }
  
  Future<void> _loadStudents() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    if (classProvider.students.isEmpty) {
      await classProvider.loadClassStudents(widget.record.classId);
    }
  }
  
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      
      // Reset edited attendance if cancelling edit
      if (!_isEditing) {
        _editedAttendance = Map<String, AttendanceStatus>.from(widget.record.studentAttendance);
      }
    });
  }
  
  void _updateAttendanceStatus(String studentId, AttendanceStatus status) {
    if (!_isEditing) return;
    
    setState(() {
      _editedAttendance[studentId] = status;
    });
  }
  
  Future<void> _saveAttendance() async {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    
    final updatedRecord = widget.record.copyWith(
      studentAttendance: _editedAttendance,
    );
    
    final success = await attendanceProvider.updateAttendanceRecord(updatedRecord);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      setState(() {
        _isEditing = false;
      });
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
    
    return LoadingOverlay(
      isLoading: classProvider.isLoading || attendanceProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance Details'),
          actions: [
            if (!_isEditing) 
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: _toggleEditMode,
              )
            else
              TextButton.icon(
                icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                label: const Text('Cancel', style: TextStyle(color: Colors.white)),
                onPressed: _toggleEditMode,
              ),
            if (_isEditing)
              TextButton.icon(
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text('Save', style: TextStyle(color: Colors.white)),
                onPressed: _saveAttendance,
              ),
          ],
        ),
        body: Column(
          children: [
            // Attendance info section
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.scaffoldDarkColor.withOpacity(0.8)
                  : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.record.className,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${widget.record.attendancePercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${widget.record.formattedDate}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Topic: ${widget.record.topic}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (widget.record.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Notes: ${widget.record.notes}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Attendance summary row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAttendanceCount(
                        label: 'Present',
                        count: widget.record.presentCount,
                        color: AppTheme.successColor,
                      ),
                      _buildAttendanceCount(
                        label: 'Absent',
                        count: widget.record.absentCount,
                        color: AppTheme.errorColor,
                      ),
                      _buildAttendanceCount(
                        label: 'Late',
                        count: widget.record.lateCount,
                        color: AppTheme.warningColor,
                      ),
                      _buildAttendanceCount(
                        label: 'Excused',
                        count: widget.record.excusedCount,
                        color: AppTheme.secondaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status filter chips
            if (_isEditing)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            // Student list with attendance
            Expanded(
              child: classProvider.students.isEmpty
                  ? const Center(
                      child: Text('No students found for this class'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: classProvider.students.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final student = classProvider.students[index];
                        final status = _editedAttendance[student.id] ?? AttendanceStatus.absent;
                        
                        return _buildStudentAttendanceItem(student, status);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttendanceCount({
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStudentAttendanceItem(Student student, AttendanceStatus status) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
        child: student.photoUrl.isNotEmpty
            ? null
            : Text(
                student.name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      title: Text(
        student.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Roll No: ${student.rollNumber}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: _isEditing
          ? _buildStatusDropdown(student.id, status)
          : AttendanceStatusChip(status: status),
    );
  }
  
  Widget _buildStatusDropdown(String studentId, AttendanceStatus status) {
    return DropdownButton<AttendanceStatus>(
      value: status,
      onChanged: (newStatus) {
        if (newStatus != null) {
          _updateAttendanceStatus(studentId, newStatus);
        }
      },
      items: AttendanceStatus.values.map((status) {
        return DropdownMenuItem<AttendanceStatus>(
          value: status,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(_getStatusLabel(status)),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  String _getStatusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }
  
  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppTheme.successColor;
      case AttendanceStatus.absent:
        return AppTheme.errorColor;
      case AttendanceStatus.late:
        return AppTheme.warningColor;
      case AttendanceStatus.excused:
        return AppTheme.secondaryColor;
    }
  }
  
  Widget _buildQuickActionButton({
    required String label,
    required AttendanceStatus status,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () {
        final classProvider = Provider.of<ClassProvider>(context, listen: false);
        
        setState(() {
          for (final student in classProvider.students) {
            _editedAttendance[student.id] = status;
          }
        });
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