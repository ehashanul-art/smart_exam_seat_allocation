import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smart_exam_seat_allocation/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'theme.dart';
import 'screens/Splash.dart';
import 'screens/Login.dart';
import 'screens/main_admin_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'screens/add_teacher.dart';
import 'screens/add_student.dart';
import 'screens/create_exam.dart';
import 'screens/add_hall.dart';
import 'screens/student_list.dart';
import 'screens/generate_seat_plan.dart';
import 'screens/main_admin_signIn.dart';
import 'screens/AddCourseScreen.dart';
import 'screens/all_teachers_screen.dart';
import 'screens/exam_list_screen.dart';
import 'screens/hall_list_screen.dart';
import 'screens/seat_plan_list_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("--- Handling a background message: ${message.messageId}");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(SmartExamApp());
}

class SmartExamApp extends StatelessWidget {
  const SmartExamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Exam Seat Allocation',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        MainAdminDashboard.routeName: (_) => MainAdminDashboard(),
        TeacherDashboard.routeName: (_) => TeacherDashboard(),
        AddTeacherScreen.routeName: (_) => AddTeacherScreen(),
        AddStudentScreen.routeName: (_) => AddStudentScreen(),
        CreateExamScreen.routeName: (_) => CreateExamScreen(),
        AddHallScreen.routeName: (_) => AddHallScreen(),
        StudentListScreen.routeName: (_) => StudentListScreen(),
        GenerateSeatPlanScreen.routeName: (_) => GenerateSeatPlanScreen(),
        MainAdminSignUp.routeName: (context) => const MainAdminSignUp(),
        AddCourseScreen.routeName: (_) => AddCourseScreen(),
        AllTeachersScreen.routeName: (_) => AllTeachersScreen(),
        ExamListScreen.routeName: (_) => const ExamListScreen(),
        HallListScreen.routeName: (_) => HallListScreen(),
        SeatPlanListScreen.routeName: (_) => const SeatPlanListScreen(),
      },
    );
  }
}