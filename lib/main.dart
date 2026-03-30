import 'package:flutter/material.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_advisor_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_attendance_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_contest_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_deal_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_document_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_lead_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_leaderboard_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_profile_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_recruitment_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_team_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/add_document_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_projects_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/advisor_applications_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/attendance_report_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/meeting_management_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/contests_list_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/create_meeting_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/docs_management_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/lead_management_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/leaderboard_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_recruitment_dashboard_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/team_management_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_dashboard_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_document_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_lead_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_dashboard_screen.dart';
import 'package:prarambh_infra/features/recruitment/presentation/providers/advisor_registration_provider.dart';
import 'package:prarambh_infra/features/client/presentation/screens/client_dashboard_screen.dart';
import 'package:prarambh_infra/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:prarambh_infra/features/recruitment/presentation/providers/recruitment_provider.dart';
import 'package:prarambh_infra/features/recruitment/presentation/screens/advisor_registration_screen.dart';
import 'package:prarambh_infra/features/recruitment/presentation/screens/recruiter_dashboard_screen.dart';
import 'package:provider/provider.dart';
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
        ChangeNotifierProvider(
          create: (_) => di.sl<AdminLeaderboardProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<AdminAttendanceProvider>()),
        ChangeNotifierProvider(
          create: (_) => di.sl<AdminRecruitmentProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<AdminTeamProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminProjectProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminLeadProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminProfileProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdvisorRegistrationProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdvisorDashboardProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<RecruitmentProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdvisorDocumentProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminDealProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdvisorLeadProvider>()),
      ],
      child: const PraarambhApp(),
    ),
  );
}

class PraarambhApp extends StatelessWidget {
  const PraarambhApp({super.key});

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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/advisor_applications': (context) => const AdvisorApplicationsScreen(),
        '/docs_management': (context) => const DocsManagementScreen(),
        '/add_document': (context) => const AddDocumentScreen(),
        '/contests_list': (context) => const ContestsListScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/create_meeting': (context) => const CreateMeetingScreen(),
        '/attendance_report': (context) => const AttendanceReportScreen(meetingId: ''),
        '/meeting_management': (context) => const MeetingManagementScreen(),
        '/admin_recruitment_dashboard': (context) => const AdminRecruitmentDashboardScreen(),
        '/team_management': (context) => const TeamManagementScreen(),
        '/admin_projects': (context) => const AdminProjectsScreen(),
        '/lead_management': (context) => const LeadManagementScreen(),
        '/advisor_dashboard': (context) => const AdvisorDashboardScreen(),
        '/client_dashboard': (context) => const ClientDashboardScreen(),
        '/advisor_registration': (context) => const AdvisorRegistrationScreen(),
        '/recruiter_dashboard' : (context) => const RecruiterDashboardScreen(),
      },
    );
  }
}
