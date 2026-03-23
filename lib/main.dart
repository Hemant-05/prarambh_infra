import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_advisor_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_attendance_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_contest_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_document_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_leaderboard_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_recruitment_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/add_document_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/advisor_applications_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/attendance_report_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/attendance_review_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/contests_list_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/create_meeting_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/docs_management_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/leaderboard_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/recruitment_dashboard_screen.dart';
import 'package:prarambh_infra/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:provider/provider.dart';

// Import the injection container
import 'injection_container.dart' as di;

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        // Ask GetIt (sl) for the AuthProvider
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminProvider>()),

        ChangeNotifierProvider(create: (_) => di.sl<AdminAdvisorProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminDocumentProvider>()),

        ChangeNotifierProvider(create: (_) => di.sl<AdminContestProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminLeaderboardProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminAttendanceProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminRecruitmentProvider>()),
      ],
      child: const PraarambhApp(),
    ),
  );
}

class PraarambhApp extends StatelessWidget {
  const PraarambhApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praarambh Infra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        primaryColor: const Color(0xFF0B5394),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF1976D2),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/admin_dashboard',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/advisor_applications': (context) => const AdvisorApplicationsScreen(),
        '/docs_management': (context) => const DocsManagementScreen(),
        '/add_document': (context) => const AddDocumentScreen(),
        '/contests_list': (context) => const ContestsListScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/create_meeting': (context) => const CreateMeetingScreen(),
        '/attendance_report': (context) => const AttendanceReportScreen(),
        '/recruitment_dashboard': (context) => const RecruitmentDashboardScreen(),
      },
    );
  }
}