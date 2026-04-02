import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_attendance_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_document_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_leaderboard_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_profile_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_project_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_recruitment_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_team_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_attendance_provider.dart';
import 'package:prarambh_infra/features/advisor/presentation/providers/advisor_contest_provider.dart';
import 'package:prarambh_infra/features/recruitment/presentation/providers/advisor_registration_provider.dart';
import 'package:provider/provider.dart';
import 'package:prarambh_infra/core/navigation/nav_service.dart';
import 'package:prarambh_infra/core/widgets/server_error_screen.dart';
import 'package:prarambh_infra/core/theme/app_colors.dart';
import 'injection_container.dart' as di;

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/admin/presentation/providers/admin_provider.dart';
import 'features/admin/presentation/providers/admin_lead_provider.dart';
import 'features/admin/presentation/providers/admin_deal_provider.dart';
import 'features/admin/presentation/providers/admin_advisor_provider.dart';
import 'features/admin/presentation/providers/admin_contest_provider.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin/presentation/screens/advisor_applications_screen.dart';
import 'features/admin/presentation/screens/docs_management_screen.dart';
import 'features/admin/presentation/screens/add_document_screen.dart';
import 'features/admin/presentation/screens/contests_list_screen.dart';
import 'features/admin/presentation/screens/leaderboard_screen.dart';
import 'features/admin/presentation/screens/create_meeting_screen.dart';
import 'features/admin/presentation/screens/attendance_report_screen.dart';
import 'features/admin/presentation/screens/meeting_management_screen.dart';
import 'features/admin/presentation/screens/admin_recruitment_dashboard_screen.dart';
import 'features/admin/presentation/screens/team_management_screen.dart';
import 'features/admin/presentation/screens/admin_projects_screen.dart';
import 'features/admin/presentation/screens/lead_management_screen.dart';
import 'features/advisor/presentation/providers/advisor_dashboard_provider.dart';
import 'features/advisor/presentation/providers/advisor_achievement_provider.dart';
import 'features/advisor/presentation/providers/advisor_lead_provider.dart';
import 'features/advisor/presentation/providers/advisor_leaderboard_provider.dart';
import 'features/advisor/presentation/screens/advisor_dashboard_screen.dart';
import 'features/advisor/presentation/screens/installment_calculator_screen.dart';
import 'features/advisor/presentation/screens/advisor_leaderboard_screen.dart';
import 'features/recruitment/presentation/providers/recruitment_provider.dart';
import 'features/recruitment/presentation/screens/recruiter_dashboard_screen.dart';
import 'features/recruitment/presentation/screens/advisor_registration_screen.dart';
import 'features/client/presentation/providers/client_dashboard_provider.dart';
import 'features/client/presentation/providers/property_filter_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminLeadProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdminDealProvider>()),
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
        ChangeNotifierProvider(create: (_) => di.sl<AdminProfileProvider>()),
        ChangeNotifierProvider(
          create: (_) => di.sl<AdvisorRegistrationProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<AdvisorDashboardProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<AdvisorAchievementProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<AdvisorLeadProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdvisorContestProvider>()),
        ChangeNotifierProvider(
          create: (_) => di.sl<AdvisorAttendanceProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<AdvisorLeaderboardProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<RecruitmentProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ClientDashboardProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<PropertyFilterProvider>()),
      ],
      child: MaterialApp(
        title: 'Prarambh Infra',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        navigatorKey: NavService.navigatorKey,
        initialRoute: '/splash',
        routes: _buildRoutes(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlueLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.surfaceLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBlueLight,
        secondary: AppColors.primaryOrangeLight,
        surface: AppColors.surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textMainLight,
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme)
          .copyWith(
            bodyMedium: GoogleFonts.montserrat(color: AppColors.textMainLight),
            bodySmall: GoogleFonts.montserrat(
              color: AppColors.textSecondaryLight,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBlueLight,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlueLight),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlueDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryBlueDark,
        secondary: AppColors.primaryOrangeDark,
        surface: AppColors.surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textMainDark,
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            bodyMedium: GoogleFonts.montserrat(color: AppColors.textMainDark),
            bodySmall: GoogleFonts.montserrat(
              color: AppColors.textSecondaryDark,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlueDark),
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
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
      '/attendance_report': (context) =>
          const AttendanceReportScreen(meetingId: ''),
      '/meeting_management': (context) => const MeetingManagementScreen(),
      '/admin_recruitment_dashboard': (context) =>
          const AdminRecruitmentDashboardScreen(),
      '/team_management': (context) => const TeamManagementScreen(),
      '/admin_projects': (context) => const AdminProjectsScreen(),
      '/lead_management': (context) => const LeadManagementScreen(),
      '/advisor_dashboard': (context) => const AdvisorDashboardScreen(),
      '/advisor_registration': (context) => const AdvisorRegistrationScreen(),
      '/recruiter_dashboard': (context) => const RecruiterDashboardScreen(),
      '/installment_calculator': (context) =>
          const InstallmentCalculatorScreen(),
      '/advisor_leaderboard': (context) => const AdvisorLeaderboardScreen(),
      '/server_error': (context) => const ServerErrorScreen(),
    };
  }
}
