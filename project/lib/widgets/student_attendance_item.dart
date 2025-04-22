import 'package:flutter/material.dart';
import 'package:teacher_attendance_app/models/attendance.dart';
import 'package:teacher_attendance_app/models/student.dart';
import 'package:teacher_attendance_app/utils/theme.dart';

class StudentAttendanceItem extends StatelessWidget {
  final Student student;
  final AttendanceStatus status;
  final Function(AttendanceStatus) onStatusChanged;
  
  const StudentAttendanceItem({
    super.key,
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Roll No: ${student.rollNumber}',
                  style: const TextStyle(
                    color: AppTheme.textGrayColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusSelector(context),
        ],
      ),
    );
  }
  
  Widget _buildStatusSelector(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusButton(
          context,
          AttendanceStatus.present,
          Icons.check_circle_outline,
          AppTheme.successColor,
        ),
        _buildStatusButton(
          context,
          AttendanceStatus.absent,
          Icons.cancel_outlined,
          AppTheme.errorColor,
        ),
        _buildStatusButton(
          context,
          AttendanceStatus.late,
          Icons.watch_later_outlined,
          AppTheme.warningColor,
        ),
        _buildStatusButton(
          context,
          AttendanceStatus.excused,
          Icons.medical_services_outlined,
          AppTheme.secondaryColor,
        ),
      ],
    );
  }
  
  Widget _buildStatusButton(
    BuildContext context,
    AttendanceStatus buttonStatus,
    IconData icon,
    Color color,
  ) {
    final isSelected = status == buttonStatus;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => onStatusChanged(buttonStatus),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : color.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : color,
            size: 20,
          ),
        ),
      ),
    );
  }
}