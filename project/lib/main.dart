import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:teacher_attendance_app/services/firebase_service.dart';
import 'package:teacher_attendance_app/services/notification_service.dart';
import 'package:teacher_attendance_app/providers/auth_provider.dart';
import 'package:teacher_attendance_app/providers/class_provider.dart';
import 'package:teacher_attendance_app/providers/attendance_provider.dart';
import 'package:teacher_attendance_app/providers/notification_provider.dart';
import 'package:teacher_attendance_app/screens/splash_screen.dart';
import 'package:teacher_attendance_app/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const TeacherAttendanceApp(),
    ),
  );
}

class TeacherAttendanceApp extends StatelessWidget {
  const TeacherAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}