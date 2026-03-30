import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/admin/presentation/providers/admin_provider.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_profile_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/admin_projects_screen.dart';
import 'package:prarambh_infra/features/admin/presentation/screens/team_management_screen.dart';
import 'admin_deals_screen.dart';

import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_home_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardData();
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
    final primaryBlue = AppColors.getPrimaryBlue(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AdminDrawer(),

      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          // 3. UPDATE THIS: Use the current index to grab the right title
          _pageTitles[_currentIndex],
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

      body: _views[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // When you tap a tab, setState updates the index,
          // which rebuilds the body AND the AppBar title instantly!
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: primaryBlue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 10),
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
