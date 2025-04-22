import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:teacher_attendance_app/models/class_model.dart';
import 'package:teacher_attendance_app/providers/attendance_provider.dart';
import 'package:teacher_attendance_app/providers/class_provider.dart';
import 'package:teacher_attendance_app/screens/attendance/mark_attendance_screen.dart';
import 'package:teacher_attendance_app/screens/classes/students_list_screen.dart';
import 'package:teacher_attendance_app/utils/theme.dart';
import 'package:teacher_attendance_app/widgets/loading_overlay.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  
  const ClassDetailScreen({super.key, required this.classId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> with SingleTickerProviderStateMixin {
  ClassModel? _class;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClassData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadClassData() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    
    final classModel = classProvider.getClassById(widget.classId);
    if (classModel != null) {
      setState(() {
        _class = classModel;
      });
      
      await classProvider.loadClassStudents(widget.classId);
      await attendanceProvider.loadClassAttendance(widget.classId);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    
    return LoadingOverlay(
      isLoading: classProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_class?.name ?? 'Class Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // TODO: Implement edit class functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit class functionality coming soon!'),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Students'),
            ],
          ),
        ),
        body: _class == null
            ? const Center(
                child: Text('Class not found'),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(_class!),
                  StudentsListScreen(classId: widget.classId),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MarkAttendanceScreen()),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.how_to_reg),
          label: const Text('Take Attendance'),
        ),
      ),
    );
  }
  
  Widget _buildOverviewTab(ClassModel classModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class info card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classModel.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              classModel.courseCode,
                              style: const TextStyle(
                                color: AppTheme.textGrayColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: classModel.isActive,
                        onChanged: (newValue) {
                          // TODO: Implement class activation/deactivation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Status update functionality coming soon!'),
                            ),
                          );
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.business_outlined,
                    label: 'Department',
                    value: classModel.department,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.schedule_outlined,
                    label: 'Schedule',
                    value: classModel.schedule,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Room',
                    value: classModel.room,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Duration',
                    value: '${DateFormat('MMM d, yyyy').format(classModel.startDate)} - ${DateFormat('MMM d, yyyy').format(classModel.endDate)}',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.people_outlined,
                    label: 'Students',
                    value: classModel.studentIds.length.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionCard(
                icon: Icons.how_to_reg,
                label: 'Take Attendance',
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MarkAttendanceScreen()),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildActionCard(
                icon: Icons.analytics_outlined,
                label: 'View Records',
                color: AppTheme.secondaryColor,
                onTap: () {
                  // TODO: Navigate to view attendance screen for this class
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionCard(
                icon: Icons.person_add_outlined,
                label: 'Add Student',
                color: AppTheme.accentColor,
                onTap: () {
                  // TODO: Navigate to add student screen
                },
              ),
              const SizedBox(width: 16),
              _buildActionCard(
                icon: Icons.message_outlined,
                label: 'Send Notice',
                color: Colors.purple,
                onTap: () {
                  // TODO: Navigate to send notice screen
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent attendance
          const Text(
            'Recent Attendance',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<AttendanceProvider>(
            builder: (context, attendanceProvider, _) {
              final recentRecords = attendanceProvider.attendanceRecords
                  .where((record) => record.classId == classModel.id)
                  .toList();
              
              if (recentRecords.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No attendance records yet',
                        style: TextStyle(color: AppTheme.textGrayColor),
                      ),
                    ),
                  ),
                );
              }
              
              // Sort by most recent
              recentRecords.sort((a, b) => b.date.compareTo(a.date));
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentRecords.length > 5 ? 5 : recentRecords.length,
                itemBuilder: (context, index) {
                  final record = recentRecords[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: record.attendancePercentage >= 75
                                  ? AppTheme.successColor
                                  : record.attendancePercentage >= 50
                                      ? AppTheme.warningColor
                                      : AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.topic,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  record.shortDate,
                                  style: const TextStyle(
                                    color: AppTheme.textGrayColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: record.attendancePercentage >= 75
                                  ? AppTheme.successColor
                                  : record.attendancePercentage >= 50
                                      ? AppTheme.warningColor
                                      : AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${record.attendancePercentage.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textGrayColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppTheme.textGrayColor,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}