import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_profile_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_projects_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/team_management_screen.dart';
import 'admin_deals_screen.dart';

import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/ui_helper.dart';
import '../providers/admin_advisor_provider.dart';
import '../providers/admin_enquiry_provider.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_home_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupErrorListeners();
      context.read<AdminProvider>().fetchDashboardData();
    });
  }

  void _setupErrorListeners() {
    // Listen to AdminProvider
    context.read<AdminProvider>().addListener(() {
      final error = context.read<AdminProvider>().errorMessage;
      if (error != null && mounted) {
        UIHelper.showError(context, UIHelper.summarizeError(error));
        context.read<AdminProvider>().clearError();
      }
    });

    // Listen to AdminEnquiryProvider
    context.read<AdminEnquiryProvider>().addListener(() {
      final error = context.read<AdminEnquiryProvider>().error;
      if (error != null && mounted) {
        UIHelper.showError(context, UIHelper.summarizeError(error));
        context.read<AdminEnquiryProvider>().clearError();
      }
    });

    // Listen to AdminAdvisorProvider
    context.read<AdminAdvisorProvider>().addListener(() {
      final error = context.read<AdminAdvisorProvider>().errorMessage;
      if (error != null && mounted) {
        UIHelper.showError(context, UIHelper.summarizeError(error));
        context.read<AdminAdvisorProvider>().clearError();
      }
    });
  }

  // 1. Your list of screens
  final List<Widget> _views = [
    const AdminHomeView(),
    const AdminProjectsScreen(),
    const AdminDealsScreen(),
    const TeamManagementScreen(),
    const AdminProfileScreen(),
  ];

  // 2. ADD THIS: A matching list of titles
  final List<String> _pageTitles = [
    'Admin Dashboard',
    'Project Management',
    'Deal Management',
    'Team Management',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthProvider>().currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final primaryBlue = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final adminProvider = context.watch<AdminProvider>();
    final currentIndex = adminProvider.dashboardIndex;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AdminDrawer(),

      appBar: AppBar(
        backgroundColor: isDark ? Theme.of(context).cardColor : primaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _pageTitles[currentIndex],
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: _views[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          adminProvider.setDashboardIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Theme.of(context).cardColor : primaryBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 10, color: Colors.white70),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Project'),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            label: 'Deals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
