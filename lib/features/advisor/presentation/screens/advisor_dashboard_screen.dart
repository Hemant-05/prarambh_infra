import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_profile_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_team_screen.dart';
import 'package:provider/provider.dart';

import 'package:prarambh_infra/features/auth/presentation/providers/auth_provider.dart';
import '../providers/advisor_dashboard_provider.dart';
import '../../data/models/advisor_dashboard_model.dart';

import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_contests_list_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_projects_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_schedule_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/document_center_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/sales_pipeline_screen.dart';
import 'package:prarambh_infra/features/advisor/presentation/screens/advisor_achievement_screen.dart';

class AdvisorDashboardScreen extends StatefulWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  State<AdvisorDashboardScreen> createState() => _AdvisorDashboardScreenState();
}

class _AdvisorDashboardScreenState extends State<AdvisorDashboardScreen> {
  String _selectedSalesTab = 'Month';
  final Color _primaryBlue = const Color(0xFF0056A4);
  int _selectedIndex = 0;

  final List<String> _appBarTitles = [
    'Business Dashboard',
    'Projects & Inventory',
    'Sales Pipeline',
    'My Team',
    'My Profile'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final advisorCode = context.read<AuthProvider>().currentUser?.advisorCode ?? '';
      context.read<AdvisorDashboardProvider>().fetchDashboardData(advisorCode);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardContent(context),
      const AdvisorProjectsScreen(),
      const SalesPipelineScreen(),
      const AdvisorTeamScreen(),
      const AdvisorProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _appBarTitles[_selectedIndex],
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _primaryBlue,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_outlined)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_rounded)), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.business_outlined)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.business)), label: 'Projects'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.trending_up_rounded)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.trending_up, size: 26)), label: 'Sales'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.people_outline)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.people)), label: 'Team'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person_outline)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.person)), label: 'Profile'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
    );
  }

  // ==========================================
  // MAIN DASHBOARD CONTENT (TAB 0)
  // ==========================================
  Widget _buildDashboardContent(BuildContext context) {
    final provider = context.watch<AdvisorDashboardProvider>();
    final advisor = context.read<AuthProvider>().currentUser;

    if (provider.isLoading || provider.data == null) {
      return Center(child: CircularProgressIndicator(color: _primaryBlue));
    }

    final data = provider.data!;

    return RefreshIndicator(
      onRefresh: () => provider.fetchDashboardData(advisor?.advisorCode ?? ''),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopProfileCard(data),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('Career Progress'),
                  _buildCareerProgress(data),
                  const SizedBox(height: 24),

                  _buildSalesConversionHeader(),
                  _buildSalesConversionCards(data.sales),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Quick Actions'),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 24),

                  _buildPendingActionsHeader(data.pendingActions.length),
                  _buildPendingActionsList(data.pendingActions),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Promotion Status'),
                  _buildPromotionStatusTable(data.promotionStatus),
                  const SizedBox(height: 24),

                  _buildActiveContestsHeader(),
                  _buildActiveContestsList(data.activeContests),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PLACEHOLDER SCREEN WIDGET
  // ==========================================
  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
            child: Icon(icon, size: 64, color: _primaryBlue.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text('$title Screen', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Coming Soon', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==========================================
  // UI WIDGET COMPONENTS
  // ==========================================
  Widget _buildTopProfileCard(AdvisorDashboardModel data) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(color: _primaryBlue, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue.shade50,
                    backgroundImage: data.profilePhoto.isNotEmpty ? NetworkImage(data.profilePhoto) : null,
                    child: data.profilePhoto.isEmpty ? Icon(Icons.person, size: 30, color: _primaryBlue) : null,
                  ),
                  Positioned(
                    bottom: -8, left: 0, right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        data.status.toUpperCase(),
                        style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.name, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                      child: Text(data.role, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('ID: ${data.advisorId}', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('Parent: ', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[700])),
                        Expanded(child: Text(data.parentName, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareerProgress(AdvisorDashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: const Color(0xFF1E2A47), borderRadius: BorderRadius.circular(12)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.star_border, color: Colors.white, size: 30),
                Positioned(
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                    child: Text('LVL', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.currentLevel, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('NEXT: ${data.nextLevel}', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryBlue)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_outward, size: 12, color: _primaryBlue),
                  ],
                ),
              ],
            ),
          ),
          Text('${data.progressPercent}%', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E2A47))),
        ],
      ),
    );
  }

  Widget _buildSalesConversionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Sales Conversion'),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: ['Month', 'Quarter', 'Year'].map((e) => GestureDetector(
              onTap: () => setState(() => _selectedSalesTab = e),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedSalesTab == e ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedSalesTab == e ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                child: Text(e, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: _selectedSalesTab == e ? _primaryBlue : Colors.grey[600])),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesConversionCards(SalesConversion sales) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(child: _buildSalesCard(sales.suspecting.toString(), 'SUSPECTING', const Color(0xFFF0F8FF), Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _buildSalesCard(sales.prospecting.toString(), 'PROSPECTING', const Color(0xFFFCE4EC), Colors.pink)),
          const SizedBox(width: 12),
          Expanded(child: _buildSalesCard(sales.siteVisit.toString(), 'SITE VISIT', const Color(0xFFE8F5E9), Colors.green)),
        ],
      ),
    );
  }

  Widget _buildSalesCard(String value, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {'icon': Icons.description_outlined, 'label': 'Document\nView'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'My Income'},
      {'icon': Icons.event_available_outlined, 'label': 'Upcoming\nInstallment'},
      {'icon': Icons.event_note_outlined, 'label': 'Attendance'},
      {'icon': Icons.calculate_outlined, 'label': 'Calculator'},
      {'icon': Icons.pie_chart_outline, 'label': 'Business Plan'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (actions[index]['label'] == 'Calculator') { Navigator.pushNamed(context, '/installment_calculator'); }
            if (actions[index]['label'] == 'Document\nView') { Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentCenterScreen())); }
            if (actions[index]['label'] == 'Attendance') { Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvisorScheduleScreen())); }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _primaryBlue.withOpacity(0.2))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(actions[index]['icon'] as IconData, color: _primaryBlue, size: 28),
                const SizedBox(height: 8),
                Text(actions[index]['label'] as String, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 10, color: _primaryBlue, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingActionsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Pending Actions'),
        Text('$count Tasks', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryBlue)),
      ],
    );
  }

  Widget _buildPendingActionsList(List<PendingAction> actions) {
    if (actions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Center(child: Text("No pending tasks! 🎉", style: GoogleFonts.montserrat(color: Colors.grey))),
      );
    }

    List<Color> iconColors = [Colors.orange, Colors.blue, Colors.green, Colors.teal];
    List<IconData> icons = [Icons.shortcut, Icons.assignment_outlined, Icons.calendar_today_outlined, Icons.schedule];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final action = actions[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColors[index % iconColors.length].withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icons[index % icons.length], color: iconColors[index % iconColors.length]),
            ),
            title: Text(action.title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: Text(action.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 11, color: Colors.grey)),
            trailing: Text(action.time, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          );
        },
      ),
    );
  }

  Widget _buildPromotionStatusTable(List<PromotionMetric> metrics) {
    if (metrics.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Center(child: Text("No promotion metrics set yet.", style: GoogleFonts.montserrat(color: Colors.grey))),
      );
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('METRIC', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                Expanded(child: Text('TARGET', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
                Expanded(child: Text('ACHIEVED', textAlign: TextAlign.right, style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]))),
              ],
            ),
          ),
          ...metrics.map((m) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(m.metric, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: m.metric.contains('Team Booking') ? FontWeight.bold : FontWeight.w500)),
                ),
                Expanded(child: Text(m.target, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold))),
                Expanded(child: Text(m.achieved, textAlign: TextAlign.right, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryBlue))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActiveContestsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Active Contests'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
          child: Text('RUNNING', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryBlue)),
        ),
      ],
    );
  }

  Widget _buildActiveContestsList(List<ActiveContest> contests) {
    if (contests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.5))),
        child: Center(child: Text("No active contests right now.", style: GoogleFonts.montserrat(color: Colors.grey))),
      );
    }

    List<IconData> icons = [Icons.military_tech_outlined, Icons.location_on_outlined, Icons.calendar_month_outlined, Icons.card_giftcard_outlined];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contests.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _primaryBlue.withOpacity(0.5))),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Icon(icons[index % icons.length], color: _primaryBlue),
            ),
            title: Text(contests[index].title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: contests[index].subtitle != null ? Text(contests[index].subtitle!, style: GoogleFonts.montserrat(fontSize: 11, color: _primaryBlue)) : null,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
  );

  // ==========================================
  // SIDE DRAWER WIDGET
  // ==========================================
  Widget _buildDrawer() {
    final provider = context.watch<AdvisorDashboardProvider>();
    final data = provider.data;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            color: Colors.white,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: data != null && data.profilePhoto.isNotEmpty ? NetworkImage(data.profilePhoto) : null,
                  child: data == null || data.profilePhoto.isEmpty ? Icon(Icons.person, size: 35, color: _primaryBlue) : null,
                ),
                const SizedBox(height: 12),
                Text(data?.name ?? 'Loading...', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${data?.role.toUpperCase() ?? ''} : #${data?.advisorId ?? ''}', style: GoogleFonts.montserrat(fontSize: 12, color: _primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(),
          _drawerItem(Icons.description_outlined, 'Document View', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentCenterScreen()));
          }),
          _drawerItem(Icons.emoji_events_outlined, 'Contests', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdvisorContestsListScreen()));
          }),
          _drawerItem(Icons.account_balance_wallet_outlined, 'My Income', () {}),
          _drawerItem(Icons.event_available_outlined, 'Upcoming Installment', () {}),
          _drawerItem(Icons.military_tech_outlined, 'Achievements', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdvisorAchievementScreen()));
          }),
          _drawerItem(Icons.calculate_outlined, 'Calculator - INSTALLMENT', () { Navigator.pushNamed(context, '/installment_calculator'); }),
          _drawerItem(Icons.badge_outlined, 'Meeting & Attendance', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdvisorScheduleScreen()));
          }),
          _drawerItem(Icons.leaderboard_outlined, 'Leader board', () { Navigator.pushNamed(context, '/advisor_leaderboard'); }),
          _drawerItem(Icons.people_outline, 'My Recruitment', () { Navigator.pushNamed(context, '/recruiter_dashboard'); }),
          _drawerItem(Icons.campaign_outlined, 'Promotions', () {}),
          _drawerItem(Icons.groups_outlined, 'Business plan - click 6 points', () {}),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('Log Out', style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
      onTap: onTap,
    );
  }
}