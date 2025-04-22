import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:teacher_attendance_app/models/class_model.dart';
import 'package:teacher_attendance_app/providers/auth_provider.dart';
import 'package:teacher_attendance_app/providers/class_provider.dart';
import 'package:teacher_attendance_app/screens/classes/class_detail_screen.dart';
import 'package:teacher_attendance_app/utils/theme.dart';
import 'package:teacher_attendance_app/widgets/loading_overlay.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  bool _showActiveOnly = true;
  
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
  
  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final List<ClassModel> classes = _showActiveOnly
        ? classProvider.getActiveClasses()
        : classProvider.classes;
    
    return LoadingOverlay(
      isLoading: classProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Classes'),
          actions: [
            IconButton(
              icon: Icon(
                _showActiveOnly ? Icons.filter_list : Icons.filter_list_off,
              ),
              onPressed: () {
                setState(() {
                  _showActiveOnly = !_showActiveOnly;
                });
              },
              tooltip: _showActiveOnly
                  ? 'Showing active classes only'
                  : 'Showing all classes',
            ),
          ],
        ),
        body: classes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showActiveOnly
                          ? 'No active classes found'
                          : 'No classes found',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Classes assigned to you will appear here',
                      style: TextStyle(
                        color: AppTheme.textGrayColor,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classModel = classes[index];
                  return _buildClassCard(classModel);
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement add class functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add class functionality coming soon!'),
              ),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
  
  Widget _buildClassCard(ClassModel classModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: classModel.isActive
            ? BorderSide.none
            : BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClassDetailScreen(classId: classModel.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      classModel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: classModel.isActive
                          ? AppTheme.successColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      classModel.isActive ? 'Active' : 'Inactive',
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
              Row(
                children: [
                  const Icon(
                    Icons.bookmark_outline,
                    size: 16,
                    color: AppTheme.textGrayColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    classModel.courseCode,
                    style: const TextStyle(
                      color: AppTheme.textGrayColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: AppTheme.textGrayColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    classModel.schedule,
                    style: const TextStyle(
                      color: AppTheme.textGrayColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.textGrayColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    classModel.room,
                    style: const TextStyle(
                      color: AppTheme.textGrayColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${classModel.studentIds.length} Students',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${DateFormat('MMM d').format(classModel.startDate)} - ${DateFormat('MMM d, yyyy').format(classModel.endDate)}',
                    style: const TextStyle(
                      color: AppTheme.textGrayColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}