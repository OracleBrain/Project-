import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:teacher_attendance_app/models/attendance.dart';
import 'package:teacher_attendance_app/models/class_model.dart';
import 'package:teacher_attendance_app/providers/attendance_provider.dart';
import 'package:teacher_attendance_app/providers/auth_provider.dart';
import 'package:teacher_attendance_app/providers/class_provider.dart';
import 'package:teacher_attendance_app/screens/attendance/attendance_detail_screen.dart';
import 'package:teacher_attendance_app/utils/theme.dart';
import 'package:teacher_attendance_app/widgets/class_dropdown.dart';
import 'package:teacher_attendance_app/widgets/loading_overlay.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  ClassModel? _selectedClass;
  int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadClasses();
  }
  
  Future<void> _loadClasses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    
    if (authProvider.teacherProfile != null && classProvider.classes.isEmpty) {
      await classProvider.loadTeacherClasses(authProvider.teacherProfile!.id);
    }
  }
  
  void _onClassSelected(ClassModel? classModel) async {
    setState(() {
      _selectedClass = classModel;
    });
    
    if (classModel != null) {
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      await attendanceProvider.loadClassAttendance(classModel.id);
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
          title: const Text('View Attendance'),
        ),
        body: Column(
          children: [
            // Class selection
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
                    classes: classProvider.classes,
                    selectedClass: _selectedClass,
                    onChanged: _onClassSelected,
                  ),
                ],
              ),
            ),
            // Tabs for different views
            if (_selectedClass != null)
              Container(
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Records'),
                    Tab(text: 'Analytics'),
                  ],
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  onTap: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
              ),
            // Content based on selected tab
            Expanded(
              child: _selectedClass == null
                  ? const Center(
                      child: Text('Please select a class to view attendance'),
                    )
                  : _selectedTabIndex == 0
                      ? _buildAttendanceRecords(attendanceProvider)
                      : _buildAttendanceAnalytics(attendanceProvider),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttendanceRecords(AttendanceProvider attendanceProvider) {
    final records = attendanceProvider.attendanceRecords;
    
    if (records.isEmpty) {
      return const Center(
        child: Text('No attendance records found for this class'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceDetailScreen(record: record),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record.formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                          '${record.attendancePercentage.toStringAsFixed(1)}%',
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
                    'Topic: ${record.topic}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Attendance summary row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAttendanceCount(
                        label: 'Present',
                        count: record.presentCount,
                        color: AppTheme.successColor,
                      ),
                      _buildAttendanceCount(
                        label: 'Absent',
                        count: record.absentCount,
                        color: AppTheme.errorColor,
                      ),
                      _buildAttendanceCount(
                        label: 'Late',
                        count: record.lateCount,
                        color: AppTheme.warningColor,
                      ),
                      _buildAttendanceCount(
                        label: 'Excused',
                        count: record.excusedCount,
                        color: AppTheme.secondaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
  
  Widget _buildAttendanceAnalytics(AttendanceProvider attendanceProvider) {
    final records = attendanceProvider.attendanceRecords;
    
    if (records.isEmpty) {
      return const Center(
        child: Text('No attendance records found for this class'),
      );
    }
    
    // Calculate averages
    double averageAttendance = 0;
    for (final record in records) {
      averageAttendance += record.attendancePercentage;
    }
    averageAttendance /= records.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              _buildAnalyticCard(
                title: 'Average Attendance',
                value: '${averageAttendance.toStringAsFixed(1)}%',
                icon: Icons.people_outline,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 16),
              _buildAnalyticCard(
                title: 'Total Classes',
                value: records.length.toString(),
                icon: Icons.calendar_today,
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Attendance Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Attendance trend chart
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.transparent,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < records.length && index % 2 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('MM/dd').format(records[index].date),
                              style: const TextStyle(
                                color: AppTheme.textGrayColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value % 20 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                color: AppTheme.textGrayColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: records.length.toDouble() - 1,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(records.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        records[index].attendancePercentage,
                      );
                    }),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryColor,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Attendance By Student',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Student wise attendance list
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                // We'll populate this with actual student data
                Text('Student attendance breakdown will appear here'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}